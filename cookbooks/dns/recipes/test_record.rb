require 'fog'

include_recipe "dns::default"

#dns_record "testrecord1-dme" do
#  domain_name "foo-dnsmadeeasy.ryangeyer.com"
#  username Fog.credentials[:dnsmadeeasy_api_key]
#  password Fog.credentials[:dnsmadeeasy_secret_key]
#  hosted_dns_provider "DNSMadeEasy"
#  record_name "testrecord"
#  record_type "A"
#  record_value "11.22.33.44"
#  fog_options :host => "api.sandbox.dnsmadeeasy.com"
#  action :nothing
#end
#
#dns_record "testrecord2-dme" do
#  domain_name "foo-dnsmadeeasy.ryangeyer.com"
#  username Fog.credentials[:dnsmadeeasy_api_key]
#  password Fog.credentials[:dnsmadeeasy_secret_key]
#  hosted_dns_provider "DNSMadeEasy"
#  record_name "testrecord"
#  record_type "A"
#  record_value "22.33.44.55"
#  fog_options :host => "api.sandbox.dnsmadeeasy.com"
#  action :nothing
#end

dns_record "testrecord1-aws" do
  domain_name "ryangeyer.com"
  username Fog.credentials[:aws_access_key_id]
  password Fog.credentials[:aws_secret_access_key]
  hosted_dns_provider "AWS"
  record_name "testrecord.ryangeyer.com"
  record_type "A"
  record_value "11.22.33.44"
  action :nothing
end

dns_record "testrecord2-aws" do
  domain_name "ryangeyer.com"
  username Fog.credentials[:aws_access_key_id]
  password Fog.credentials[:aws_secret_access_key]
  hosted_dns_provider "AWS"
  record_name "testrecord.ryangeyer.com"
  record_type "A"
  record_value "22.33.44.55"
  action :update
end