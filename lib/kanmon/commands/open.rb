require "yao"
require "yaml"
require "kanmon/commands/base"

module Kanmon
  module Commands
    class Open < Base
      option :file, default: "kanmon.yml", desc: "config file path"

      def call(**options)
        id = YAML.load_file(options.fetch(:file))["security_group"]
        ip = myip
        rule = {
          direction: "ingress",
          port_range_min: 22,
          port_range_max: 22,
          ethertype: "IPv4",
          protocol: "tcp",
          remote_ip_prefix: "#{ip}/32",
          security_group_id: id,
        }

        Yao::SecurityGroupRule.create(rule)
        puts "Success!!"
      end
    end

    register "open", Open
  end
end
