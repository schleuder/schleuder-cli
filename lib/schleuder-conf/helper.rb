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

    def url(listname=nil, *args)
      u = "/lists/#{listname}"
      if args
        u << "/#{args.join('/')}"
      end
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

    def delete(url)
      req = Net::HTTP::Delete.new(url)
      request(req)
    end

    def request(req)
      resp = api.request(req)
      case resp.code.to_i
      when 404
        fatal resp.body
      when 400
        fatal "Error: #{resp.body}"
      when 500
        fatal 'Server error, try again later'
      else
        JSON.parse(resp.body)
      end
    rescue Errno::ECONNREFUSED
      fatal "Error: Cannot connect to schleuderd at #{api.address}:#{api.port}, please check if it's running."
      exit 1
    end

    def getlist(listname)
      get("/lists/#{listname}")
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

    def show_or_set_config(object, option, value)
      if option.blank?
        list_options(object)
      elsif value.blank?
        show_config_value(object, option)
      else
        set_config_value(object, option, value)
      end
    end

    def list_options(object)
      say "Available options:\n\n#{object.class.configurable_attributes.join("\n")}"
    end

    def show_config_value(object, option)
      if object.respond_to?(option)
        show_value object.send(option)
      elsif object[option].present?
        show_value object[option]
      else
        fatal "No such config-option: '#{option}'"
      end
    end

    def set_config_value(object, option, value)
      case value.strip
      when /\A\[.*\]\z/
        # Convert input into Array
        value = value.gsub('[', '').gsub(']', '').split(/,\s/)
      when /\A\{.*\}\z/
        # Convert input into Hash
        tmp = value.gsub('{', '').gsub('}', '').split(/,\s/)
        value = tmp.inject({}) do |hash, pair|
          k,v = pair.split(/:\s|=>\s/)
          hash[k.strip] = v.strip
          hash
        end
      end
      object[option] = value
      if object.save
        show_value object.send(option)
      else
        object.errors.each do |attrib, message|
          error "#{attrib} #{message}"
        end
      end
    end

  end
end
