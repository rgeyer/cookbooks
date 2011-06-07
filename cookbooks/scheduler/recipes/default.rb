#
# Cookbook Name:: schedule
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

if node[:platform] != "windows"
  # TODO: Verify support for CentOS, maybe I need to install vixie-cron too?
  package value_for_platform("centos" => { "default" => "crontabs" }, "default" => "cron") do
    action :upgrade
  end

else
  directory node[:scheduler][:powershell_libs_dir] do
    recursive true
    action :create
  end

  if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
    %w{win32_task_create.ps1 win32_task_delete.ps1}.each do |lib|
      cookbook_file ::File.join(node[:scheduler][:powershell_libs_dir], lib) do
        source lib
      end
    end
  else
    %w{win32_task_create.ps1 win32_task_delete.ps1}.each do |lib|
      remote_file ::File.join(node[:scheduler][:powershell_libs_dir], lib) do
        source lib
      end
    end
  end
end

%w{hourly daily}.each do |frequency|
  script_path = ::File.join(node[:scheduler][:script_dir], "#{frequency}#{node[:scheduler][:script_ext]}")

  directory ::File.join(node[:scheduler][:script_dir], frequency) do
    recursive true
    action :create
  end

  template script_path do
    source "default_schedule.erb"
    variables(:frequency => frequency)
  end

  if node[:platform] == "windows"
    case frequency
      when "hourly" then hour_freq = 1
      when "daily"  then hour_freq = 24
    end

    powershell "scheduler_#{frequency}_tasks" do
      parameters({
        "NAME" => "scheduler_#{frequency}_tasks",
        "USERNAME" => node[:scheduler][:username],
        "PASSWORD" => node[:scheduler][:password],
        "COMMAND" => script_path,
        "HOURLY_FREQUENCY" => hour_freq,
        "DAILY_TIME" => node[:scheduler][:daily_time]
      })

      source_path(::File.join(node[:scheduler][:powershell_libs_dir], "win32_task_create.ps1"))
    end
  else
    daily_time_parts = node[:scheduler][:daily_time]
    hour = daily_time_parts[0]
    minute = daily_time_parts[1]

    cron "scheduler_#{frequency}_tasks" do
      if frequency == "hourly"
        minute "0"
      else
        hour hour
        minute minute
      end
      command script_path
    end
  end
end