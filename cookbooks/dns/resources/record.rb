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

actions :create, :update, :delete

attribute :domain_name, :kind_of => String, :required => true
attribute :username, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :hosted_dns_provider, :kind_of => String, :equal_to => ["AWS", "DNSMadeEasy"], :required => true
attribute :record_name, :kind_of => String, :required => true
attribute :record_type, :kind_of => String, :equal_to => ["A", "AAAA", "MX", "CNAME", "NS", "PTR", "HTTP", "SRV", "TXT"], :required => true
attribute :record_value, :kind_of => [String,Array], :required => true

# Fully optional
attribute :fog_options, :kind_of => Hash, :required => false
attribute :record_ttl, :kind_of => Integer, :required => false, :default => 3600