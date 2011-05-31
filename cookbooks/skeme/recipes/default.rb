#
# Cookbook Name:: skeme
# Recipe:: default
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

gemfile="/tmp/skeme.gem"

require 'socket'

skeme_version = "0.0.5"

if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
  f = cookbook_file gemfile do
    source "skeme-#{skeme_version}.gem"
    action :nothing
  end
else
  f = remote_file gemfile do
    source "skeme-#{skeme_version}.gem"
    action :nothing
  end
end

f.run_action(:create)

# Install rest_connection in the RightScale sandbox, if it exists.
if ::File.directory? node[:rs_sandbox][:home]
  load_ruby_gem_into_rs_sandbox(gemfile, skeme_version, nil, false)
end

# Install rest_connection for the system, if we're on linux
# TODO: This currently only supports *nix OS's because there is no "system" ruby for windows.
if node[:platform] != "windows"
  g = gem_package gemfile do
    version skeme_version
    action :nothing
  end

  g.run_action(:install)
end

Gem.clear_paths
require "skeme"