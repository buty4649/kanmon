module Kanmon
  module Commands
    class Version < Hanami::CLI::Command
      def call(*)
        puts "v#{Kanmon::VERSION}"
      end
    end

    register "version", Version
  end
end
