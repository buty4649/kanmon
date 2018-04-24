require "thor"
require "shellwords"

require "kanmon/securitygroup"

module Kanmon
  class CLI < Thor
    class_option :file, aliases: "f", type: :string, default: "kanmon.yml", banner: "FILE", desc: "Load configure from FILE"

    desc "open", "Commands about add rules to SecurityGroup"
    def open
      @sg.open
      puts "Success!!"
    end

    desc "close", "Commands about delete rules from SecurityGroup"
    def close
      @sg.close
      puts "Success!!"
    end

    desc "ssh", "Commands about open, run ssh, close"
    def ssh(*args)
      @sg.open

      begin
        Process.wait spawn("ssh #{Shellwords.join(args)}")
      ensure
        @sg.close
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
          @sg = SecurityGroup.new(@config["security_group"])
        end

        super
      end
    end
  end
end
