#
# Cookbook Name:: ebs_conductor
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
include_recipe "skeme::default"

ebs_conductor_version = "0.0.4"

if node[:platform] == "ubuntu"
  package "xfsprogs"
end

unless node[:ebs_conductor_installed]
  # Install ebs_conductor in the RightScale sandbox, if it exists.
  if ::File.directory? node[:rs_sandbox][:home]
    load_ruby_gem_into_rs_sandbox("ebs_conductor", ebs_conductor_version, nil, false)
  end

  # Install rest_connection for the system, if we're on linux
  # TODO: This currently only supports *nix OS's because there is no "system" ruby for windows.
  if node[:platform] != "windows"
    g = gem_package gemfile do
      version ebs_conductor_version
      action :nothing
    end

    g.run_action(:install)
  end

  node[:ebs_conductor_installed] = true
end

Gem.clear_paths
require "ebs_conductor"

# We know that fog is installed as a dependency of ebs_conductor, which is installed by including the default recipe above
require 'rubygems'
require 'fog'

region = node[:ec2][:placement_availability_zone].gsub(/[a-z]*$/, '')
fog = Fog::Compute.new({:region => region, :provider => 'AWS', :aws_access_key_id => node[:aws][:access_key_id], :aws_secret_access_key => node[:aws][:secret_access_key]})
instance_id = node[:ec2][:instance_id]

node[:ebs_conductor][:current_volumes] = fog.volumes.all('attachment.instance-id' => instance_id)
used_devices = node[:ebs_conductor][:current_volumes].collect {|vol| vol.device }
node[:ebs_conductor][:available_devices] = node[:ebs_conductor][:valid_ebs_devices] - used_devices
node[:ebs_conductor][:available_devices].reverse!