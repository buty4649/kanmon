require "yaml"

module Kanmon
  class Config
    def self.load_file(filepath)
      data = if filepath
               YAML.load_file(filepath)
             else
               default_files = [File.expand_path("~/.kanmon.yml"), "./kanmon.yml"]
               config_file = default_files.find {|path| File.exists?(path)}
               YAML.load_file(config_file)
             end

      new(data)
    end

    def initialize(data)
      @data = data
    end

    def targets
      @data.keys
    end

    def set(target)
      unless @data.keys.include?(target)
        raise TargetNotFoundError.new("#{target} is not found.")
      end
      @target = target
    end

    %w(security_group server port exclude_ips).each do |name|
      define_method(name) do
        if @target
          @data[@target][name]
        else
          @data[name]
        end
      end
    end
  end
end