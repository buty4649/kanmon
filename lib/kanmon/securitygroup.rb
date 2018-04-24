require "yao"

require "kanmon/myip"

module Kanmon
  class SecurityGroup
    def initialize(id, ip = nil)
      @id = id
      @ip = ip || Kanmon::MyIP.get
    end

    def open
      rule = {
        direction: "ingress",
        port_range_min: 22,
        port_range_max: 22,
        ethertype: "IPv4",
        protocol: "tcp",
        remote_ip_prefix: "#{@ip}/32",
        security_group_id: @id,
      }

      Yao::SecurityGroupRule.create(rule)
    end

    def close
      tenant_id = Yao.current_tenant_id

      rule = {
        direction: "ingress",
        port_range_min: 22,
        port_range_max: 22,
        ethertype: "IPv4",
        protocol: "tcp",
        security_group_id: @id,
        tenant_id: tenant_id,
        remote_ip_prefix: "#{@ip}/32"
      }

      result = Yao::SecurityGroupRule.list(rule)
      raise "Not found" if result.empty?

      result.each do |rule|
        id = rule.id
        puts "Delete #{id}"
        Yao::SecurityGroupRule.destroy(id)
      end
    end
  end
end
