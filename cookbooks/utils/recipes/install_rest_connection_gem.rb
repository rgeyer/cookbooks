rest_connection_version="0.0.15"

require 'socket'

include_recipe "ruby_gems::default"

install_command = "install --both --no-rdoc --no-force --no-test --no-ri --ignore-dependencies"
install_command += " --version 0.0.15 rest_connection"
if node[:platform] == "windows"
  # NOTE: For Windows, this installs the rest_connection config yaml file only for the RightScale_1 user, so if you try
  # to use it for other stuff like, say a scheduled windows task that runs as administrator, you'd be hosed.
  `LocateSandbox && SET PATH=%RS_SANDBOX_PATH%\Ruby\bin;%PATH% && gem #{install_command}`

  a.run_action(:install)

else
  # Installs for the servers system environment
  b = gem_package "rest_connection" do
    version rest_connection_version
    action :nothing
  end

  # Installs for the RightScale sandbox
  c = gem_package "rest_connection" do
    version rest_connection_version
    gem_binary "/opt/rightscale/sandbox/bin/gem"
    action :nothing
  end
end

b.run_action(:install)
c.run_action(:install)

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