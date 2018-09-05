module Kanmon
  class ExcludeIps
    def initialize(ips)
      @ips = ips || Array.new
    end

    def include?(ip)
      @ips.include?(ip)
    end
  end
end
