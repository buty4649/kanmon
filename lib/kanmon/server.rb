require "yao"

require "kanmon/myip"
require "kanmon/error"

module Kanmon
  class Server
    attr_reader :ip
    attr_accessor: :user_name

    def initialize(id, port, ip = nil)
      @id = id
      @port = port || 22
      @ip = ip || Kanmon::MyIP.get
      @tenant_id = Yao.current_tenant_id
      @server = Yao::Server.get(id)
      @user_name = ENV['OS_USERNAME']
    end

    def create_sg
      puts "Create security group allow to access server '#{@server.name}'."
      param = {name: sg_name, description: "create by kanmon and #{ENV['OS_USERNAME']}"}
      @sg = Yao::SecurityGroup.create(param)
      result = Yao::SecurityGroupRule.create(rule)
      puts "Create rule to #{@sg.name} allow ssh from #{@ip}/32: #{result.id}"
    end

    def delete_sg
      puts "Delete security group #{sg_name}"
      Yao::SecurityGroup.destroy(@sg.id)
    end

    def add_sg
      puts "Add security group  #{sg_name} to server #{@server.name}"
      Yao::Server.add_security_group(@id, sg_name)
    end

    def validate_sg_already_exists
      if Yao::SecurityGroup.list({name: sg_name}).size > 0
        puts "Security Group #{sg_name} already exists."
        puts "Is not it already opened?"
        raise Kanmon::AlreadySecurityExistsError
      end
    end

    def remove_sg
      puts "Remove security group #{sg_name} from server '#{@server.name}'."
      Yao::Server.remove_security_group(@id, sg_name)
    end

    def open
      validate_sg_already_exists
      create_sg
      add_sg

      if block_given?
        begin
          yield
        ensure
          remove_sg
          delete_sg
        end
      end
    end

    def close
      begin
        result = Yao::SecurityGroup.find_by_name(sg_name)
        if @sg = result.first
          remove_sg
          delete_sg
        end
      rescue => e
        p e
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
          security_group_id: @sg.id,
          tenant_id: @tenant_id,
          remote_ip_prefix: "#{@ip}/32"
      }
    end

    def sg_name
      "kanmon-server:#{@server.id}-user:#{user_name}"
    end
  end
end
