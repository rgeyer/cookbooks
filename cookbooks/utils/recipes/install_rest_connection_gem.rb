rest_connection_version="0.0.15"

require 'socket'

`#{rs_sandbox_gem_bin} sources --add 'http://rubygems.org'` unless `#{rs_sandbox_gem_bin} sources --list | findstr 'http://rubygems.org'`

rs_sandbox_gem_bin=value_for_platform("windows" => {"default" => "#{`echo %RS_SANDBOX_HOME%`.strip}\\Ruby\\bin\\gem.bat"}, "default" => "/opt/rightscale/sandbox/bin/gem")

if node[:platform] != "windows"
  include_recipe "rubygems::default"
  Chef::Log.info("Installing the rest_connection #{rest_connection_version} gem for the system Ruby runtime")
  # Installs for the servers system environment
  gem_package "rest_connection" do
    version rest_connection_version
    action :install
  end
else
  # NOTE: For Windows, this installs the rest_connection config yaml file only for the RightScale_1 user, so if you try
  # to use it for other stuff like, say a scheduled windows task that runs as administrator, you'd be hosed.

  `#{rs_sandbox_gem_bin} sources --add 'http://rubygems.org'` unless `#{rs_sandbox_gem_bin} sources --list | findstr 'http://rubygems.org'`

  # Installs for the RightScale sandbox
  c = gem_package "rest_connection" do
    version rest_connection_version
    gem_binary rs_sandbox_gem_bin
    action :nothing
  end

  Chef::Log.info("Installing the rest_connection #{rest_connection_version} gem for the system Ruby runtime, using gem binary #{rs_sandbox_gem_bin}")

  c.run_action(:install) if ::File.exists? rs_sandbox_gem_bin
end

Gem.clear_paths

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