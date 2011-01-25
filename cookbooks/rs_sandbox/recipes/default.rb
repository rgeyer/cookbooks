#
# Cookbook Name:: rs_sandbox
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

grep_bin = value_for_platform("windows" => {"default" => "findstr"}, "default" => "grep")

node[:rs_sandbox][:gem_bin] = value_for_platform("windows" => {"default" => "#{`echo %RS_SANDBOX_HOME%`.strip}\\Ruby\\bin\\gem.bat"}, "default" => "/opt/rightscale/sandbox/bin/gem")

gem_source_already_added = `#{node[:rs_sandbox][:gem_bin]} sources --list | #{grep_bin} 'http://rubygems.org'`

unless gem_source_already_added
  Chef::Log.info("Adding http://rubygems.org to gem source for RightScale sandbox")
  `#{node[:rs_sandbox][:gem_bin]} sources --add 'http://rubygems.org'`
end