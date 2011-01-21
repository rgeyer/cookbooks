#
# Cookbook Name:: aws
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

g = ruby_gems_package "aws-s3" do
  action :nothing
end

g.run_action(:install)

Gem.clear_paths