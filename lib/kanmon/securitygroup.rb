require "yao"

require "kanmon/myip"

module Kanmon
  class SecurityGroup
    def initialize(id, ip = nil)
      @id = id
      @ip = ip || Kanmon::MyIP.get
      @tenant_id = Yao.current_tenant_id
    end

    def open
      Yao::SecurityGroupRule.create(rule)

      if block_given?
        begin
          yield
        ensure
          close
        end
      end
    end

    def close
      result = Yao::SecurityGroupRule.list(rule)
      raise "Not found" if result.empty?

      result.each do |rule|
        id = rule.id
        puts "Delete #{id}"
        Yao::SecurityGroupRule.destroy(id)
      end
    end

    private
    def rule
      {
        direction: "ingress",
        port_range_min: 22,
        port_range_max: 22,
        ethertype: "IPv4",
        protocol: "tcp",
        security_group_id: @id,
        tenant_id: @tenant_id,
        remote_ip_prefix: "#{@ip}/32"
      }
    end
  end
end
