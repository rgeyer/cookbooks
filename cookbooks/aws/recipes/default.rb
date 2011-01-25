#
# Cookbook Name:: aws
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#g = ruby_gems_package "aws-s3" do
#  action :nothing
#end
#
#g.run_action(:install)

r = gem_package "right_aws" do
  action :nothing
end

r.run_action(:install)

require 'rubygems'
Gem.clear_paths
require 'right_aws'

# Installs for the servers system environment
b = gem_package "aws-s3" do
  action :nothing
end

# Installs for the RightScale sandbox
c = gem_package "aws-s3" do
  gem_binary "/opt/rightscale/sandbox/bin/gem"
  action :nothing
end

b.run_action(:install)
c.run_action(:install)

Gem.clear_paths