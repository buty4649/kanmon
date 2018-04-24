require "thor"
require "shellwords"

require "kanmon/myip"

module Kanmon
  class CLI < Thor
    class_option :file, aliases: "f", type: :string, default: "kanmon.yml", banner: "FILE", desc: "Load configure from FILE"

    desc "open", "Commands about add rules to SecurityGroup"
    def open
      myip = Kanmon::MyIP.get
      rule = {
        direction: "ingress",
        port_range_min: 22,
        port_range_max: 22,
        ethertype: "IPv4",
        protocol: "tcp",
        remote_ip_prefix: "#{myip}/32",
        security_group_id: @config["security_group"],
      }

      Yao::SecurityGroupRule.create(rule)
      puts "Success!!"
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    def close
      myip = Kanmon::MyIP.get
      tenant_id = Yao.current_tenant_id

      rule = {
        direction: "ingress",
        port_range_min: 22,
        port_range_max: 22,
        ethertype: "IPv4",
        protocol: "tcp",
        security_group_id: @config["security_group"],
        tenant_id: tenant_id,
        remote_ip_prefix: "#{myip}/32"
      }

      result = Yao::SecurityGroupRule.list(rule)

      if result.empty?
        puts "Not found"
        exit(1)
      end

      result.each do |rule|
        id = rule.id
        puts "Delete #{id}"
        Yao::SecurityGroupRule.destroy(id)
      end

      puts "Success!!"
    end

    desc "ssh", "Commands about open, run ssh, close"
    def ssh(*args)
      invoke CLI, [:open], {}

      begin
        Process.wait spawn("ssh #{Shellwords.join(args)}")
      ensure
        invoke CLI, [:close], {}
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
          @config = Kanmon.load_config(options[:file])
        end

        super
      end
    end
  end
end
