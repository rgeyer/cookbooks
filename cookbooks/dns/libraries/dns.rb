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

begin
  puts require 'fog'
rescue LoadError
  Chef::Log.warn("fog gem not loaded, make sure dns::default has been run")
end

module Rgeyer
  module Chef
    module Dns
      def zone_exists?
        # AWS adds a '.' to the end of the domain name
        fog_dns.zones.select { |z| (z.domain =~ /^#{new_resource.domain_name}\.?$/) != nil }.count > 0
      end

      def record_exists? (zone, recordname)
        zone.records.select { |r| (r.name =~ /^#{recordname}\.?$/) != nil }.count > 0
      end

      def fog_dns
        options_hash = new_resource.fog_options || {}

        # Map username/password to the appropriate values for the fog provider.
        case new_resource.hosted_dns_provider
          when "AWS"
            options_hash.merge!({:aws_access_key_id => new_resource.username, :aws_secret_access_key => new_resource.password})
          when "DNSMadeEasy"
            options_hash.merge!({:dnsmadeeasy_api_key => new_resource.username, :dnsmadeeasy_secret_key => new_resource.password})
        end

        @@fog_dns ||= Fog::DNS.new(options_hash.merge({:provider => new_resource.hosted_dns_provider}))
      end

      def zone_by_name (domainname)
        if zone_exists?
          zones = fog_dns.zones.select{ |z| (z.domain =~ /^#{domainname}\.?$/) != nil }
          zone = zones.first
          fog_dns.zones.get(zone.id)
        else
          nil
        end
      end

      def record_by_name (zone, recordname)
        if zone && record_exists?(zone, recordname)
          records = zone.records.select{ |r| (r.name =~ /^#{recordname}\.?$/) != nil}
          record = records.first
          # Check for Rte53 or DNSMadeEasy, meta the save method for Rte53 & return as is
          # return "get record" for DNSMadeEasy
          zone.records.get(record.id)
        else
          nil
        end
      end
    end
  end
end