require "yaml"

module Kanmon
  class Config
    def initialize(options={})
      config_file = options[:kanmon_config]
      target = options[:target]
      @config = YAML.load_file(config_file)

      if target
        @config = @config[target]
      end
    end

    def keys
      @config.keys
    end

    %w(security_group server port exclude_ips).each do |name|
      define_method(name) do
        @config[name]
      end
    end
  end
end