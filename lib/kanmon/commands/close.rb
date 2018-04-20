require "yao"
require "yaml"
require "kanmon/commands/base"

module Kanmon
  module Commands
    class Close < Base
      option :file, default: "kanmon.yml", desc: "config file path"

      def call(**options)
        id = YAML.load_file(options.fetch(:file))["security_group"]
        tenant_id = Yao.current_tenant_id

        rule = {
          direction: "ingress",
          port_range_min: 22,
          port_range_max: 22,
          ethertype: "IPv4",
          protocol: "tcp",
          security_group_id: id,
          tenant_id: tenant_id,
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
    end

    register "close", Close
  end
end
