rest_connection_version="0.0.15"

require 'socket'

include_recipe "ruby_gems::default"

ruby_gems_package "rest_connection" do
  version rest_connection_version
  action :install
end

ruby_gems_package "i18n" do
  action :install
end

directory value_for_platform("windows" => {"default" => "C:/Users/RightScale_1/.rest_connection"}, "default" => "/etc/rest_connection") do
  recursive true
  action :create
end

template value_for_platform("windows" => {"default" => "C:/Users/RightScale_1/.rest_connection/rest_api_config.yaml"}, "default" => "/etc/rest_connection/rest_api_config.yaml") do
  source "rest_api_config.yaml.erb"
  variables(
    :rest_pass => node[:utils][:rest_pass],
    :rest_user => node[:utils][:rest_user],
    :rest_acct_num => node[:utils][:rest_acct_num]
  )
end

# A useful way to find "this" instance when running scripts that use rest_connection
# Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
right_link_tag "ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"