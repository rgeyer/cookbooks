require 'fog'

include_recipe "dns::default"

# For AWS

#dns_zone "foo-amazon.ryangeyer.com" do
#  domain_name "foo-amazon.ryangeyer.com"
#  username Fog.credentials[:aws_access_key_id]
#  password Fog.credentials[:aws_secret_access_key]
#  hosted_dns_provider "AWS"
#  description "described"
#  action [:create, :delete]
#end


# For DNSMadeEasy

dns_zone "foo-dnsmadeeasy.ryangeyer.com" do
  domain_name "foo-dnsmadeeasy.ryangeyer.com"
  username Fog.credentials[:dnsmadeeasy_api_key]
  password Fog.credentials[:dnsmadeeasy_secret_key]
  hosted_dns_provider "DNSMadeEasy"
  description "described"
  fog_options :host => "api.sandbox.dnsmadeeasy.com"
  #action [:create, :delete]
  action :create
end