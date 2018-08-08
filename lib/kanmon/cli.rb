require "thor"
require "shellwords"

require "kanmon/securitygroup"

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
      if @config.key?('security_group')
        @sg.open
      end

      if @config.key?('server')
        server = Yao::Server.get(@config['server'])
        puts "Create security group allow to access server '#{server.name}'."
        param = {name: "kanmon-server:#{server.id}-user:#{ENV['OS_USERNAME']}", description: "create by kanmon and #{ENV['OS_USERNAME']}"}
        sg = Yao::SecurityGroup.create(param)
        rule = {
            direction: "ingress",
            port_range_min: 22,
            port_range_max: 22,
            ethertype: "IPv4",
            protocol: "tcp",
            security_group_id: sg.id,
            tenant_id: Yao.current_tenant_id,
            remote_ip_prefix: "#{Kanmon::MyIP.get}/32"
        }
        result = Yao::SecurityGroupRule.create(rule)
        puts "Create rule to #{sg.name} allow ssh from #{Kanmon::MyIP.get}/32: #{result.id}"
        p Yao::Server.add_security_group(server.id, sg.name)
      end

      puts "Success!!"
    rescue Yao::Conflict => e
      puts "Is not it already opened?" if e.message.include?("Security group rule already exists.")
      puts e
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    def close
      if @config.key?('security_group')
        @sg.close
      end

      if @config.key?('server')
        server = Yao::Server.get(@config['server'])
        sg_name = "kanmon-server:#{server.id}-user:#{ENV['OS_USERNAME']}"
        puts "Detach security group #{sg_name} from server '#{server.name}'."
        Yao::Server.remove_security_group(server.id, sg_name)
        puts "Delete security group: #{sg_name}"
        sg = Yao::SecurityGroup.get(sg_name)
        Yao::SecurityGroup.destroy(sg.id)
      end
      puts "Success!!"
    end

    desc "ssh HOSTNAME", "Commands about exec ssh"
    def ssh(*args)
      invoke CLI, [:exec], args.unshift("ssh")
    end

    desc "exec COMMAND", "Commands about open, exec command, close"
    def exec(*args)
      @sg.open do
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
          @sg = SecurityGroup.new(@config["security_group"])
        end

        super
      end
    end
  end
end
