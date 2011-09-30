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

require 'yaml'

include Rgeyer::Chef::Dns

action :create do
  if zone_exists?
    Chef::Log.info("Creating DNS record #{new_resource.record_name} with value #{new_resource.record_value} for #{new_resource.hosted_dns_provider} hosted DNS provider")
    zone = zone_by_name(new_resource.domain_name)
    record = zone.records.new({:value => new_resource.record_value, :name => new_resource.record_name, :type => new_resource.record_type, :ttl => new_resource.record_ttl})
    record.save()
  else
    Chef::Log.error("The zone (#{new_resource.domain_name}) does not exist, a record could not be created")
  end
end

action :update do
  if zone_exists?
    Chef::Log.info("Updating DNS record #{new_resource.record_name} value to #{new_resource.record_value} for #{new_resource.hosted_dns_provider} hosted DNS provider")
    zone = zone_by_name(new_resource.domain_name)
    record = record_by_name(zone, new_resource.record_name)
    if record
      record.value = new_resource.record_value
      record.ttl = new_resource.record_ttl
      record.type = new_resource.record_type
      #record = zone.records.new({:value => new_resource.record_value, :name => new_resource.record_name, :type => new_resource.record_type, :ttl => new_resource.record_ttl})
      record.save()
    else
      Chef::Log.error("The record (#{new_resource.record_name}) does not exist and therefore could not be updated")
    end
  else
    Chef::Log.error("The zone (#{new_resource.domain_name}) does not exist, a record could not be updated")
  end
end