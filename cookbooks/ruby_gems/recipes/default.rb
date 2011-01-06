#
# Cookbook Name:: ruby_gems
# Recipe:: default
#
# Copyright 2010, Ryan J. Geyer
#
# All rights reserved - Do Not Redistribute
#

if node[:platform] == 'windows'
  rs_sandbox_exec "Add http://rubygems.org to gem sources for RightScale sandbox" do
    code <<-EOF
if (!(cmd /c gem sources --list | findstr 'http://rubygems.org')) {
  cmd /c gem sources --add 'http://rubygems.org'
}
    EOF
  end
else
  include_recipe "rubygems::default"

  bash "Add http://rubygems.org to gem sources for RightScale sandbox" do
    code <<-EOF
/opt/rightscale/sandbox/bin/gem sources --add 'http://rubygems.org'
    EOF
    not_if "/opt/rightscale/sandbox/bin/gem sources --list | grep http://rubygems.org"
  end
end