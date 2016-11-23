module SchleuderConf
  module Helper

    def api
      @http ||= begin
          host = Conf.api['host']
          port = Conf.api['port']
          http = Net::HTTP.new(host, port)
          if Conf.api_use_tls?
            require 'openssl_ssl_patch'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.verify_callback = lambda { |*a| ssl_verify_callback(*a) }
            #http.ca_file = Conf.api_cert_file
          end
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
          "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}"
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
        $stderr.puts "SchleuderConf: #{msg}"
      end
    end

    def request(req, &block)
      test_mandatory_config
      if Conf.api_use_tls? || Conf.api['host'] == 'localhost'
        req.basic_auth 'schleuder', Conf.api_key
      end
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
      when /read server hello A: unknown protocol/
        fatal "Error: Trying to connect via TLS but API is not served via TLS, check your settings."
      else
        fatal exc.message
      end
    rescue EOFError => exc
      # TODO: Find a better way to catch this.
      fatal "Error: Trying to connect without TLS but API is served via TLS, check your settings."
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

    def show_value(value)
      case value
      when nil
        error "No such option"
      when Array, Hash
        say value.inspect
      else
        say value
      end
      exit
    end

    def list_options(object)
      say "Available options:\n\n#{object.class.configurable_attributes.join("\n")}"
    end

    def ok
      say "Ok."
      exit 0
    end

    def import_key(listname, keyfile)
      test_file(keyfile)
      keydata = File.read(keyfile)
      if ! keydata.match('BEGIN PGP')
        keydata = Base64.encode64(keydata)
      end
      post(url(:keys, {list_id: listname}), {keymaterial: keydata})
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
      fingerprint == Conf.api['tls_fingerprint']
    end

    def test_mandatory_config
      if Conf.api['tls_fingerprint'].to_s.empty?
        fatal "Error: 'tls_fingerprint' is empty, can't verify remote server without it (in #{ENV['SCHLEUDER_CONF_CONFIG']})."
      end
      if Conf.api['host'].to_s.empty?
        fatal "Error: 'host' is empty, can't connect (in #{ENV['SCHLEUDER_CONF_CONFIG']})."
      end
      if Conf.api['port'].to_s.empty?
        fatal "Error: 'port' is empty, can't connect (in #{ENV['SCHLEUDER_CONF_CONFIG']})."
      end
      if Conf.api_key.empty? && Conf.api_use_tls?
        fatal "Error: 'api_key' is empty but required if 'use_tls' is true (in #{ENV['SCHLEUDER_CONF_CONFIG']})."
      end
    end
  end
end
