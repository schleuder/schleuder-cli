module SchleuderCli
  class Conf
    attr_accessor :filename

    DEFAULTS = {
        'api' => {
          'host' => 'localhost',
          'port' => 4443,
          'use_tls' => false,
          'tls_fingerprint' => nil
          },
        'api_key' => nil
      }

    def initialize(filename)
      @config ||= load_config(filename)
      @filename = filename
    end

    def api
      @config['api'] || {}
    end

    def api_use_tls?
      api['use_tls'].to_s == "true"
    end

    def api_key
      @config['api_key'].to_s
    end

    def api_cert_file
      path = api['remote_cert_file'].to_s
      if path.empty?
        fatal "Error: remote_cert_file is empty, can't verify remote server without it (in #{self.filename})."
      end
      file = Pathname.new(api['remote_cert_file'].to_s).expand_path
      if ! file.readable?
        fatal "Error: remote_cert_file is set to a not readable file (in #{self.filename})."
      end
      file.to_s
    end


    private

    def load_config(filename)
      file = Pathname.new(filename)
      if file.exist?
        load_config_file(file)
      else
        write_defaults_to_config_file(file)
      end
    end

    def load_config_file(file)
      if ! file.readable?
        fatal "Error: #{file} is not readable."
      end
      yaml = YAML.load(file.read)
      if ! yaml.is_a?(Hash)
        fatal "Error: #{file} cannot be parsed correctly, please fix it. (To get a new default configuration file remove the current one and run again.)"
      end
      yaml
    end

    def write_defaults_to_config_file(file)
      dir = file.dirname
      if ! dir.writable?
        fatal "Error: '#{dir}' is not writable, cannot write default config to '#{file}'."
      end
      # Strip the document starting dashes. We don't need them, they only confuse people.
      yaml = DEFAULTS.to_yaml.lines[1..-1].join
      file.open('w', 0600) do |fh|
        fh.puts yaml
      end
      puts "NOTE: A default configuration file has been written to #{file}."
      DEFAULTS
    end

    def fatal(msg)
      $stderr.puts msg
      exit 1
    end

  end
end
