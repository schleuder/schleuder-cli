module SchleuderCli
  class Conf
    include Singleton

    def config
      @config ||= self.class.load_config('schleuder-cli', ENV['SCHLEUDER_CLI_CONFIG'])
    end

    def self.load_config(defaults_basename, filename)
      # TODO: copy default config if not present yet? Makes things more obvious to users.
      merge_recursively(load_defaults(defaults_basename), load_config_file(filename))
    end

    def self.api
      instance.config['api'] || {}
    end

    def self.api_use_tls?
      api['use_tls'].to_s == "true"
    end

    def self.api_key
      instance.config['api_key'].to_s
    end

    def self.api_cert_file
      path = api['remote_cert_file'].to_s
      if path.empty?
        fatal "Error: remote_cert_file is empty, can't verify remote server without it (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      file = Pathname.new(api['remote_cert_file'].to_s).expand_path
      if ! file.readable?
        fatal "Error: remote_cert_file is set to a not readable file (in #{ENV['SCHLEUDER_CLI_CONFIG']})."
      end
      file.to_s
    end


    private

    # There's no deep_merge in plain ruby, so we bake our own simple version.
    def self.merge_recursively(a, b)
      if a.is_a?(Hash) && b.is_a?(Hash)
        a.merge(b) do |key, a_item, b_item|
          merge_recursively(a_item, b_item)
        end
      else
        b || a
      end
    end

    def self.load_config_file(filename)
      file = Pathname.new(filename)
      if file.readable?
        YAML.load(file.read)
      else
        {}
      end
    end

    def self.load_defaults(basename)
      file = Pathname.new(ENV['SCHLEUDER_CLI_ROOT']).join("etc/#{basename}.yml")
      if ! file.readable?
        raise RuntimError, "Error: '#{file}' is not a readable file."
      end
      load_config_file(file)
    end
  end
end
