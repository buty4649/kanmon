require "yao"
require "yaml"

require "kanmon/cli"

module Kanmon

  def self.init_yao
    Yao.configure do
      auth_url             ENV['OS_AUTH_URL']
      tenant_name          ENV['OS_TENANT_NAME']
      username             ENV['OS_USERNAME']
      password             ENV['OS_PASSWORD']
      ca_cert              ENV['OS_CACERT']
      client_cert          ENV['OS_CERT']
      client_key           ENV['OS_KEY']
      region_name          ENV['OS_REGION_NAME']
      identity_api_version ENV['OS_IDENTITY_API_VERSION']
      user_domain_name     ENV['OS_USER_DOMAIN_NAME']
      project_domain_name  ENV['OS_PROJECT_DOMAIN_NAME']
      debug                ENV['YAO_DEBUG']
    end
  end

end
