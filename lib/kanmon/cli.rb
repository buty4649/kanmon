require "thor"
require "shellwords"

require "kanmon/securitygroup"
require "kanmon/server"

module Yao::Resources
  class Server < Yao::Resources::Base
    def self.add_security_group(server_id, security_group_name)
      action(server_id, {"addSecurityGroup": {"name": security_group_name}})
    end

    def self.remove_security_group(server_id, security_group_name)
      action(server_id, {"removeSecurityGroup": {"name": security_group_name}})
    end
  end
end

module Kanmon
  class CLI < Thor
    class_option :kanmon_config, aliases: "f", type: :string, default: "kanmon.yml", banner: "FILE", desc: "Load configure from FILE"

    desc "open", "Commands about add rules to SecurityGroup"
    def open
      @kanmon.open

      puts "Success!!"
    rescue Yao::Conflict => e
      puts "Is not it already opened?" if e.message.include?("Security group rule already exists.")
      puts e
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    def close
      @kanmon.close

      if @config.key?('server')
        @server.close
      end

      puts "Success!!"
    end

    desc "ssh HOSTNAME", "Commands about exec ssh"
    def ssh(*args)
      invoke CLI, [:exec], args.unshift("ssh")
    end

    desc "exec COMMAND", "Commands about open, exec command, close"
    def exec(*args)
      @kanmon.open do
        command = Shellwords.join(args)
        Process.wait spawn(command)
      end
    end

    desc "version", "Commands about show version"
    def version
      puts Kanmon::VERSION
    end

    no_commands do
      def invoke_command(command, *args)
        unless %w(help version).include?(command.name)
          Kanmon.init_yao
          @config = Kanmon.load_config(options[:kanmon_config])
          if @config.key?("security_group")
            @kanmon = SecurityGroup.new(@config["security_group"])
          end
          if @config.key?('server')
            @kanmon = Server.new(@config["server"])
          end
        end

        super
      end
    end
  end
end
