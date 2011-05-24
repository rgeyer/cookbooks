#
# Cookbook Name:: utils
# Recipe:: install_rest_connection_gem
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

include_recipe "rs_sandbox::default"

require 'socket'
rest_connection_version="0.0.15"

# Install rest_connection in the RightScale sandbox, if it exists.
if ::File.directory? node[:rs_sandbox][:home]
  load_ruby_gem_into_rs_sandbox("i18n", nil, nil, true)
  load_ruby_gem_into_rs_sandbox("rest_connection", rest_connection_version, nil, false)
end

# Install rest_connection for the system, if we're on linux
# TODO: This currently only supports *nix OS's because there is no "system" ruby for windows.
if node[:platform] != "windows"
  g = gem_package "rest_connection" do
    version rest_connection_version
    action :nothing
  end

  g.run_action(:install)

  Gem.clear_paths
  require gem_name
end

# If credentials were provided, create the settings/credentials file
if node[:utils] && node[:utils][:rest_pass] && node[:utils][:rest_user] && node[:utils][:rest_acct_num]
  d = directory value_for_platform("windows" => {"default" => "#{node[:rs_sandbox][:rl_user_home_dir]}/.rest_connection"}, "default" => "/etc/rest_connection") do
    recursive true
    action :nothing
  end

  d.run_action(:create)

  t = template value_for_platform("windows" => {"default" => "#{node[:rs_sandbox][:rl_user_home_dir]}/.rest_connection/rest_api_config.yaml"}, "default" => "/etc/rest_connection/rest_api_config.yaml") do
    source "rest_api_config.yaml.erb"
    variables(
      :rest_pass => node[:utils][:rest_pass],
      :rest_user => node[:utils][:rest_user],
      :rest_acct_num => node[:utils][:rest_acct_num]
    )
    action :nothing
  end

  t.run_action(:create)
end

# A useful way to find "this" instance when running scripts that use rest_connection
# Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
skeme_tag "ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}" do
  action :add
end