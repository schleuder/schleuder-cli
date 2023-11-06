module SchleuderCli
  module Helper

    def api
      @http ||= begin
          http = Net::HTTP.new(Conf.host, Conf.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.verify_callback = lambda { |*a| ssl_verify_callback(*a) }
          #http.ca_file = Conf.remote_cert_file
          http
        end
    end

    def url(*args)
      if args.last.is_a?(Hash)
        params = args.pop
      end
      u = "/#{args.join('/')}.json"
      if params
        paramstring  = params.map do |k,v|
          "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
        end.join('&')
        u << "?#{paramstring}"
      end
      u
    end

    def get(url)
      req = Net::HTTP::Get.new(url)
      request(req)
    end

    def post(url, payload, &block)
      req = Net::HTTP::Post.new(url)
      req.body = payload.to_json
      req.content_type = 'application/json'
      request(req, &block)
    end

    def patch(url, payload)
      req = Net::HTTP::Patch.new(url)
      req.body = payload.to_json
      req.content_type = 'application/json'
      request(req)
    end

    def delete_req(url)
      req = Net::HTTP::Delete.new(url)
      request(req)
    end

    def debug(msg)
      if $DEBUG
        $stderr.puts "SchleuderCli: #{msg}"
      end
    end

    def request(req, &block)
      test_mandatory_config
      req.basic_auth 'schleuder', Conf.api_key
      debug "Request to API: #{req.inspect}"
      debug "API request path: #{req.path.inspect}"
      debug "API request headers: #{req.to_hash.inspect}"
      debug "API request body: #{req.body.inspect}"
      if block
        resp = block.call(api, req)
      else
        resp = api.request(req)
      end
      debug "Response from API: #{resp.inspect}"
      debug "API response headers: #{resp.to_hash.inspect}"
      debug "API response body: #{resp.body}"
      handle_response_errors(resp)
      handle_response_messages(resp)
      parse_body(resp.body)
    rescue Errno::ECONNREFUSED
      fatal "Error: Cannot connect to Schleuder API at #{api.address}:#{api.port}, please check if it's running."
    rescue Net::ReadTimeout => exc
      error "Error: Timeout while waiting for server."
      # If you set the timeout explicitly you'll have the exception passed on
      # in order to react explicitly, too.
      if timeout.to_i > 0
        raise exc
      end
    rescue OpenSSL::SSL::SSLError => exc
      case exc.message
      when /certificate verify failed/
        fatal exc.message.split('state=').last.capitalize
      else
        fatal exc.message
      end
    rescue => exc
      fatal exc.message
    end

    def handle_response_errors(response)
      case response.code.to_i
      when 404
        fatal response.body
      when 401
        fatal "Authentication failed, please check your API key."
      when 400
        if body = parse_body(response.body)
          fatal "Error: #{body['errors']}"
        else
          fatal "Unknown error"
        end
      when 500
        fatal 'Server error, try again later'
      end
    end

    def handle_response_messages(response)
      messages = response.header['X-Messages'].to_s.split(' // ')
      if ! messages.empty?
        say "\n"
        messages.each do |message|
          say " ! #{message}"
        end
        say "\n"
      end
    end

    def parse_body(body)
      if body.to_s.empty?
        nil
      else
        JSON.parse(body)
      end
    end

    def fatal(msgs)
      Array(msgs).each do |msg|
        error msg
      end
      exit 1
    end

    def check_option_presence(hash, option)
      if ! hash.has_key?(option)
        fatal "No such option"
      end
    end

    def show_value(value)
      case value
      when Array, Hash
        say value.inspect
      else
        say value
      end
      exit
    end

    def ok
      say "Ok."
      exit 0
    end

    def say_key_import_stati(import_stati)
      Array(import_stati).each do |import_status|
        say "Key #{import_status['fpr']}: #{import_status['action']}"
      end
    end

    def say_key_import_result(keys)
      keys.each do |key|
        if key['import_action'] == 'error'
          say "Unexpected error while importing key #{key['fingerprint']}"
        else
          say "#{key['import_action'].capitalize}: #{key['summary']}"
        end
      end
    end

    def import_key_and_find_fingerprint(listname, keyfile)
      return nil if keyfile.to_s.empty?

      fingerprints = import_key(listname, keyfile)

      if fingerprints.size == 1
        fingerprints.first
      else
        say "#{keyfile} contains more than one key, cannot determine which fingerprint to use. Please set it manually!"
        nil
      end
    end

    def import_key(listname, keyfile)
      test_file(keyfile)
      keydata = File.binread(keyfile)
      if ! keydata.match('BEGIN PGP')
        keydata = Base64.encode64(keydata)
      end
      result = post(url(:keys, {list_id: listname}), {keymaterial: keydata})
      if result.has_key?("keys")
        # API is v5 or later.
        num = result["keys"].size
        if num == 0
          say "#{keyfile} did not contain any keys!"
          return nil
        end
        say_key_import_result(result["keys"])
        result["keys"].map { |key| key["fingerprint"] }
      else
        # API is v4 or earlier.
        num = result["considered"]
        if num == 0
          say "#{keyfile} did not contain any keys!"
          return nil
        end
        say_key_import_stati(result['imports'])
        result['imports'].map { |import| import['fpr'] }
      end
    end

    def test_file(filename)
      if ! File.readable?(filename)
        fatal "File not found: #{filename}"
      end
    end

    def subscribe(listname, email, fingerprint, adminflag=false)
      res = post(url(:subscriptions, {list_id: listname}), {
          email: email,
          fingerprint: fingerprint.to_s,
          admin: adminflag.to_s
        })
      if res && res['errors']
        print "Error subscribing #{email}: "
        show_errors(res['errors'])
      end
      text = "#{email} subscribed to #{listname} "
      if fingerprint
        text << "with fingerprint #{fingerprint}."
      else
        text << "without setting a fingerprint."
      end
      say text
    end

    def show_errors(errors)
      Array(errors).each do |k,v|
        if v
          say "#{k.capitalize} #{v.join(', ')}"
        else
          say k
        end
      end
      exit 1
    end

    def ssl_verify_callback(pre_ok, cert_store)
      cert = cert_store.chain[0]
      # Only really compare if we're looking at the last cert in the chain.
      if cert.to_der != cert_store.current_cert.to_der
        return true
      end
      fingerprint = OpenSSL::Digest::SHA256.new(cert.to_der).to_s
      fingerprint == Conf.tls_fingerprint
    end

    def test_mandatory_config
      if Conf.host.empty?
        fatal "Error: 'host' is empty, can't connect (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      if Conf.port.empty?
        fatal "Error: 'port' is empty, can't connect (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      if Conf.tls_fingerprint.empty?
        fatal "Error: 'tls_fingerprint' is empty but required (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      if Conf.api_key.empty?
        fatal "Error: 'api_key' is empty but required (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
    end
  end
end
