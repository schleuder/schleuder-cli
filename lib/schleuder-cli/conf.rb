module SchleuderCli
  class Conf
    include Singleton

    FINGERPRINT_REGEXP = /\A0?x?[a-f0-9]{32,}\z/i

    DEFAULTS = {
        'host' => 'localhost',
        'port' => 4443,
        'tls_fingerprint' => nil,
        'api_key' => nil
      }

    def config
      @config ||= load_config(ENV['SCHLEUDER_CLI_CONFIG'])
    end

    def self.host
      instance.config['host'].to_s
    end

    def self.port
      instance.config['port'].to_s
    end

    def self.tls_fingerprint
      instance.config['tls_fingerprint'].to_s
    end

    def self.api_key
      instance.config['api_key'].to_s
    end

    def self.remote_cert_file
      path = instance.config['remote_cert_file'].to_s
      if path.empty?
        fatal "Error: remote_cert_file is empty, can't verify remote server without it (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      file = Pathname.new(path).expand_path
      if ! file.readable?
        fatal "Error: remote_cert_file is set to a not readable file (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
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
      # Test for old, nested config
      if ! yaml['api'].nil?
        self.class.fatal "Your configuration file is outdated, please fix it: Remove the first level key called 'api', and move the keys below it to the first level. It should look like this (possibly with different values):\n\n#{defaults_as_yaml}"
      end
      yaml
    end

    def write_defaults_to_config_file(file)
      dir = file.dirname
      if dir.dirname.writable?
        dir.mkdir(0700)
      else
        fatal "Error: '#{dir}' is not writable, cannot write default config to '#{file}'."
      end
      file.open('w', 0600) do |fh|
        fh.puts defaults_as_yaml
      end
      puts "NOTE: A default configuration file has been written to #{file}."
      DEFAULTS
    end

    def fatal(msg)
      self.class.fatal(msg)
    end

    def self.fatal(msg)
      $stderr.puts msg
      exit 1
    end

    def defaults_as_yaml
      # Strip the document starting dashes. We don't need them, they only confuse people.
      DEFAULTS.to_yaml.lines[1..-1].join
    end
  end
end
