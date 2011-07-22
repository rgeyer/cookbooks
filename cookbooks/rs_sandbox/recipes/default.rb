#
# Cookbook Name:: rs_sandbox
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

grep_bin = value_for_platform("windows" => {"default" => "findstr"}, "default" => "grep")

# TODO: Is there a better way to do this? Like an attributes/windows.rb file?
if node[:platform] == "windows"
  node[:rs_sandbox][:home] = `echo %RS_SANDBOX_HOME%`.strip
  node[:rs_sandbox][:gem_bin] = "#{node[:rs_sandbox][:home]}\\Ruby\\bin\\ruby.exe #{node[:rs_sandbox][:home]}\\Ruby\\bin\\gem"
  node[:rs_sandbox][:rl_user_home_dir] = `echo %USERPROFILE%`.strip
  
  gem_source_already_added = `#{node[:rs_sandbox][:gem_bin]} sources --list | #{grep_bin} "http://rubygems.org"`
  
  if gem_source_already_added.strip == ""
    Chef::Log.info("Adding http://rubygems.org to gem source for RightScale sandbox")
    `#{node[:rs_sandbox][:gem_bin]} sources --add http://rubygems.org/`
  end
else
  t = template "/root/.gemrc" do
    source "gemrc.erb"
  end
  
  t.run_action(:create)
end

