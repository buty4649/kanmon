require 'hanami/cli'

module Kanmon
  module Commands
    extend Hanami::CLI::Registry

    require "kanmon/commands/open"
    require "kanmon/commands/version"
  end
end
