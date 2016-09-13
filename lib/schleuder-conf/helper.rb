module SchleuderConf
  module Helper

    def api
      @http ||= begin
          # The hostname and ssl-usage will be configurable in the
          # future. We must tighten and ssl-enable schleuderd
          # before.
          host = 'localhost'
          http = Net::HTTP.new(host, options.port)
          #ssl = false
          #if ssl
          #  http.use_ssl = true
          #  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          #  # TODO: Fix path
          #  pem = File.read("/path/to/my.pem")
          #  http.cert = OpenSSL::X509::Certificate.new(pem)
          #  http.key = OpenSSL::PKey::RSA.new(pem)
          #end
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
      request(req, &block)
    end

    def put(url, payload)
      req = Net::HTTP::Put.new(url)
      req.body = payload.to_json
      request(req)
    end

    def patch(url, value)
      req = Net::HTTP::Patch.new(url)
      req.body = payload.to_json
      request(req)
    end

    # 'options' is reserved by Thor
    def options_req(url)
      req = Net::HTTP::Options.new(url)
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
      fatal "Error: Cannot connect to schleuderd at #{api.address}:#{api.port}, please check if it's running."
    rescue Net::ReadTimeout => exc
      error "Error: Timeout while waiting for server."
      # If you set the timeout explicitly you'll have the exception passed on
      # in order to react explicitly, too.
      if timeout.to_i > 0
        raise exc
      end
    end

    def handle_response_errors(response)
      case response.code.to_i
      when 404
        fatal response.body
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
      messages = response.header['X-Messages'].to_s.gsub('//', "\n")
      if ! messages.empty?
        say "\n ! Notice: #{messages}\n\n"
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
        puts value.inspect
      else
        puts value
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
        show_errors(res['errors'])
      end
    end

    def show_errors(errors)
      errors.each do |k,v|
        if v
          say "#{k.capitalize} #{v.join(', ')}"
        else
          say k
        end
      end
      exit 1
    end
  end
end
