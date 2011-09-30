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

action :update do
  Chef::Log.info("Updating DNSMadeEasy using DDNSID #{new_resource.record_name} to point to #{new_resource.record_value}")

  # Shamelessly copied from RightScale's scripts and RightLink https://github.com/rightscale/right_link/blob/master/chef/lib/providers/dns_dnsmadeeasy_provider.rb
  query = "username=#{new_resource.username}&password=#{new_resource.password}&id=#{new_resource.record_name}&ip=#{new_resource.record_value}"
  curl_options = '-S -s --retry 7 -k -o - -g -f'
  dnsmadeeasy_host = new_resource.fog_options[:host] || "www.dnsmadeeasy.com"
  dnsmadeeasy_url = "https://#{dnsmadeeasy_host}/servlet/main"
  if !!(RUBY_PLATFORM =~ /mswin/)
    res = `curl #{curl_options} \"#{dnsmadeeasy_url}?#{query}\"`
  else
    res = `curl #{curl_options} '#{dnsmadeeasy_url}?#{query}'`
  end
  if res =~ /success|error-record-ip-same/
    Chef::Log.info("DNSID #{new_resource.record_name} set to this instance IP: #{new_resource.record_value}")
  else
    raise "Error setting #{new_resource.record_name} to instance IP: #{new_resource.record_value}: Result: #{res}"
  end
end