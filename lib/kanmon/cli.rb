require "thor"
require "shellwords"

require "kanmon/version"
require "kanmon/securitygroup"
require "kanmon/server"
require "kanmon/exclude_ips"
require "kanmon/config"

module Kanmon
  class CLI < Thor
    class_option :config_file, aliases: "f", type: :string, default: nil, banner: "FILE", desc: "Specifies an alternate configuration file. (Default: ~/.kanmon.yml or ./kanmon.yml)"
    class_option :target, aliases: "t", type: :string, default: nil, banner: "TARGET", desc: "If more than one Security Group is in the setting, select target"

    desc "open", "Commands about add rules to SecurityGroup"
    def open
      adapter = load_adapter(config)
      adapter.open
      puts "Success!!"
    rescue Yao::Conflict => e
      puts "Is not it already opened?" if e.message.include?("Security group rule already exists.")
      puts e
    rescue Kanmon::AlreadySecurityExistsError
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    method_option :all, aliases: "a", type: :boolean, default: false, desc: "If set, close all Security Groups(Exclusive witeh --target)"
    def close
      if options[:all] && options[:target].nil?
        config.targets.each do |name|
          puts "Checking #{name}"
          config.set(name)
          adapter = load_adapter(config)
          adapter.close
        end
      else
        adapter = load_adapter(config)
        adapter.close
      end
      puts "Success!!"
    end

    desc "ssh [args]", "Commands about exec ssh"
    def ssh(*args)
      ssh_args = args.unshift("ssh", options[:target])
      invoke :exec, ssh_args
    end

    desc "exec COMMAND", "Commands about open, exec command, close"
    def exec(*args)
      adapter = load_adapter(config)
      adapter.open do
        command = Shellwords.join(args)
        Process.wait spawn(command)
      end
    end

    desc "list", "Commands about list targets"
    def list
      puts config.targets.sort.join("\n")
    end

    desc "version", "Commands about show version"
    def version
      puts Kanmon::VERSION
    end

    no_commands do
      def config
        if @__config.nil?
          @__config = Config.load_file(options[:config_file])
        end

        if target = options[:target]
          @__config.set(target)
        end

        @__config
      end

      def load_adapter(opts)
        Kanmon.init_yao

        adapter = if opts.security_group
                    SecurityGroup.new(opts.security_group, opts.port)
                  elsif opts.server
                    Server.new(opts.server, opts.port)
                  end

        exclude_ips = ExcludeIps.new(opts.exclude_ips)
        if exclude_ips.include?(adapter.ip)
          puts "MyIP(#{adapter.ip}) is included in exclude IPs."
          exit
        end

        adapter
      end
    end
  end
end
