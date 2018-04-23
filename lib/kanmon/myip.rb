require "net/http"
require "uri"

module Kanmon
  module MyIP
    def self.get
      res = Net::HTTP.get URI.parse('https://checkip.amazonaws.com/')
      res.chomp
    end
  end
end
