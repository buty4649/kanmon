require "thor"
require "shellwords"

require "kanmon/securitygroup"

module Kanmon
  class CLI < Thor
    class_option :kanmon_config, aliases: "f", type: :string, default: "kanmon.yml", banner: "FILE", desc: "Load configure from FILE"

    desc "open", "Commands about add rules to SecurityGroup"
    def open
      @sg.open
      puts "Success!!"
    rescue Yao::Conflict => e
      puts "Is not it already opened?" if e.message.include?("Security group rule already exists.")
      puts e
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    def close
      @sg.close
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
