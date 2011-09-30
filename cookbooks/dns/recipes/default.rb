#
# Cookbook Name:: dns
# Recipe:: default
#
# Copyright 2010, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "rs_sandbox::default"

fog_version = "~> 0.9.0"

# Install ebs_conductor in the RightScale sandbox, if it exists.
if ::File.directory? node[:rs_sandbox][:home]
  load_ruby_gem_into_rs_sandbox("fog", fog_version)
end

# Install fog for the system, if we're on linux
# TODO: This currently only supports *nix OS's because there is no "system" ruby for windows.
if node[:platform] != "windows"
  g = gem_package "fog" do
    version fog_version
    action :nothing
  end

  g.run_action(:install)
end

Chef::Log.info("Running fog version #{Fog::VERSION}")