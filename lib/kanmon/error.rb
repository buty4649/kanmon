
module Kanmon
  class AlreadySecurityExistsError < StandardError
    def initialize(msg="Security Group already exists.")
      super
    end
  end
end