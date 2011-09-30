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

include Rgeyer::Chef::Dns

action :create do
  unless zone_exists?
    description = new_resource.description || "DNS Zone created with the DNS OpsCode Chef cookbook by Ryan Geyer - https://github.com/rgeyer/cookbooks"
    new_zone = fog_dns.zones.new({:domain => new_resource.domain_name, :description => description})
    new_zone.save
    Chef::Log.info("Created zone (#{new_zone.domain}).  The assigned nameservers are;")
    new_zone.nameservers.each do |ns|
      Chef::Log.info(ns)
    end
  else
    Chef::Log.info("The zone (#{new_resource.domain_name}) already exists, no zone was created or updated...")
  end
end

action :delete do
  # zone_exists? gets checked again inside the method, might want to make this more efficient
  if zone_exists?
    zone_by_name(new_resource.domain_name).destroy
    Chef::Log.info("Deleted zone (#{new_resource.domain_name}).")
  end
end