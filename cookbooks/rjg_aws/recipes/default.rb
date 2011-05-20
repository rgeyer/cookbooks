#
# Cookbook Name:: aws
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'yaml'

include_recipe "rs_sandbox::default"

gem_name = "right_aws"
gem_version = "2.0.0"

if ::File.directory? node[:rs_sandbox][:home]
  load_ruby_gem_into_rs_sandbox(gem_name, gem_version, nil, true)
end

# TODO: This currently only supports *nix OS's because there is no "system" ruby for windows.
if node[:platform] != "windows"
  g = gem_package gem_name do
    if gem_version
      version gem_version
    end
    action :nothing
  end

  g.run_action(:install)

  Gem.clear_paths
  require gem_name
end