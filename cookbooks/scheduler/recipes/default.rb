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

    utilities_scheduled_tasks "scheduler_#{frequency}_tasks" do
      username node[:scheduler][:username]
      password node[:scheduler][:password]
      command script_path
      hourly_frequency hour_freq
      daily_time node[:scheduler][:daily_time]
      action :create
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