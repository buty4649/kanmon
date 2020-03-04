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
    def close
      adapter = load_adapter(config)
      adapter.close
      puts "Success!!"
    end

    desc "ssh HOSTNAME", "Commands about exec ssh"
    def ssh(*args)
      invoke :exec, args.unshift("ssh")
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
      puts Config.new(options).keys.sort.join("\n")
    end

    desc "version", "Commands about show version"
    def version
      puts Kanmon::VERSION
    end

    no_commands do
      def config
        @__config ||= Config.new(options)
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
