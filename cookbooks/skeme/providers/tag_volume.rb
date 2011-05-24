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

include Opscode::Aws::Ec2
include Rgeyer::Chef::Skeme

require 'socket'
require 'yaml'

action :add do
  ::Chef::Log.info("We're in tag_volume add action")
  rest_tag_retval = run_rest_connection {
    ::Chef::Log.info("We're in the run_rest_connection block which ought to be yielded.")
    instance = Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
    ::Chef::Log.info instance.to_yaml
    server = Server.find(:first) { |s| instance["href"].start_with? s.href }
    ::Chef::Log.info server.to_yaml
    Tag.set(server.current_instance_href, ["foo:bar=baz"])
  }
end