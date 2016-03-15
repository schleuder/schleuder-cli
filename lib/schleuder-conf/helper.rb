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

    def post(url, payload)
      req = Net::HTTP::Post.new(url)
      req.body = payload.to_json
      request(req)
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

    def request(req)
      debug "Request to API: #{req.inspect}"
      debug "API request path: #{req.path.inspect}"
      debug "API request headers: #{req.to_hash.inspect}"
      debug "API request body: #{req.body.inspect}"
      resp = api.request(req)
      debug "Response from API: #{resp.inspect}"
      debug "API response headers: #{resp.to_hash.inspect}"
      debug "API response body: #{resp.body}"
      case resp.code.to_i
      when 404
        fatal resp.body
      when 400
        if body = parse_body(resp.body)
          fatal "Error: #{body['errors']}"
        else
          fatal "Unknown error"
        end
      when 500
        fatal 'Server error, try again later'
      else
        parse_body(resp.body)
      end
    rescue Errno::ECONNREFUSED
      fatal "Error: Cannot connect to schleuderd at #{api.address}:#{api.port}, please check if it's running."
      exit 1
    rescue Net::ReadTimeout
      fatal "Error: Timeout while waiting for server."
      exit 1
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
  end
end
