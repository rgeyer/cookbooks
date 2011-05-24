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

def tag(action)
  tag       = new_resource.name
  ec2_tag   = new_resource.ec2_tag  || tag
  rs_tag    = new_resource.rs_tag   || tag
  chef_tag  = new_resource.chef_tag || tag

  rs_cli = action == "add" ? "rs_tag -a #{rs_tag}" : "rs_tag -r #{rs_tag}"

  if right_link_tag_exists?
    right_link_tag rs_tag
  elsif `which rs_tag`
    `#{rs_cli}`
  else
    rest_tag_retval = run_rest_connection {
      instance = Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
      server = Server.find(:first) { |s| instance["href"].start_with? s.href }
      Tag.set(server.current_instance_href, rs_tag)
    }
    if !rest_tag_retval
      Chef::Log.info("Not running on a RightScale server, and no RightScale API credentials were supplied. Skipping RightScale tag.")
    end
  end

  if node[:ec2] && new_resource.aws_access_key && new_resource.aws_secret_access_key
    if action == "add"
      ec2.create_tags(instance_id, ec2_tag)
    else
      ec2.delete_tags(instance_id, ec2_tag)
    end
  elsif !new_resource.aws_access_key || !new_resource.aws_secret_access_key
    Chef::Log.info("Running on an Amazon EC2 instance, but no AWS credentials were provided, skipping EC2 tag.")
  else
    Chef::Log.info("Not running on an Amazon EC2 instance, skipping EC2 tag.")
  end

  # TODO: Consider a mechanism that will work even in RightScale and Chef-Solo
  if (Chef::VERSION && Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.10.0'))
    if action == "add"
      if !node[:tags].include? chef_tag
        node[:tags] << chef_tag
      end
    else
      if node[:tags].include? chef_tag
        node[:tags] = node[:tags].delete(chef_tag)
      end
    end
  else
    Chef::Log.info("Chef version is older than 0.10.0, skipping Chef tag")
  end
end

action :add do
  tag("add")
end

action :delete do
  tag("delete")
end