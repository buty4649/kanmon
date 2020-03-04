require "yaml"

module Kanmon
  class Config
    attr_reader :target

    def initialize(options={})
      if config_file = options[:config_file]
        @config = YAML.load_file(config_file)
      else
        config_file = default_config_files.find {|path| File.exists?(path)}
        @config = YAML.load_file(config_file)
      end

      if @target = options[:target]
        @config = @config[@target]
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

    private
    def default_config_files
      [
        File.expand_path("~/.kanmon.yml"),
        "./kanmon.yml",
      ]
    end
  end
end