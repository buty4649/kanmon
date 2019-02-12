require "yao"

require "kanmon/myip"

module Kanmon
  class SecurityGroup
    attr_reader :ip

    def initialize(id, port, ip = nil)
      @id = id
      @port = port || 22
      @ip = ip || Kanmon::MyIP.get
      @tenant_id = Yao.current_tenant_id
    end

    def open
      result = Yao::SecurityGroupRule.create(rule)
      puts "Added Rule: #{result.id}"

      if block_given?
        begin
          yield
        ensure
          delete_rules([result])
        end
      end
    end

    def close
      result = Yao::SecurityGroupRule.list(rule)

      if result.empty?
        puts "Rule not found"
      else
        delete_rules(result)
      end
    end

    private
    def rule
      {
        direction: "ingress",
        port_range_min: @port,
        port_range_max: @port,
        ethertype: "IPv4",
        protocol: "tcp",
        security_group_id: @id,
        tenant_id: @tenant_id,
        remote_ip_prefix: "#{@ip}/32"
      }
    end

    def delete_rules(rules)
      rules.each do |rule|
        id = rule.id
        puts "Delete Rule: #{id}"
        Yao::SecurityGroupRule.destroy(id)
      end
    end
  end
end
