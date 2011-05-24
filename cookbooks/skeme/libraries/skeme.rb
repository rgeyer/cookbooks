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
  require 'rest_connection'
rescue
  Chef::Log.warn("The rest_connection ruby gem is not available, try running utils::install_rest_connection_gem..")
end

require 'socket'

module Rgeyer
  module Chef
    module Skeme

      def tag
        @@tag ||= new_resource.name
      end

      def ec2_tag
        @@ec2_tag = new_resource.ec2_tag || tag
      end

      def rs_tag
        @@rs_tag = new_resource.rs_tag || tag
      end

      def chef_tag
        @@chef_tag = new_resource.chef_tag || tag
      end

      def right_link_tag_exists?
        klass = Module.const_get("Chef::Provider::RightLinkTag")
        return klass.is_a?(Class)
      rescue NameError
        return false
      end

      def run_rest_connection
        # TODO: Set logger to Chef::Log
        if new_resource.rs_email && new_resource.rs_pass && new_resource.rs_acct_num
          RightScale::Api::BaseExtend.class_eval <<-EOF
          @@connection ||= RestConnection::Connection.new
            @@connection.settings = {
              :user => "#{new_resource.rs_email}",
              :pass => "#{new_resource.rs_pass}",
              :api_url => "https://my.rightscale.com/api/acct/#{new_resource.rs_acct_num}",
              :common_headers => {
                "X_API_VERSION" => "1.0"
              }
            }
          EOF
          RightScale::Api::Base.class_eval <<-EOF
          @@connection ||= RestConnection::Connection.new
            @@connection.settings = {
              :user => "#{new_resource.rs_email}",
              :pass => "#{new_resource.rs_pass}",
              :api_url => "https://my.rightscale.com/api/acct/#{new_resource.rs_acct_num}",
              :common_headers => {
                "X_API_VERSION" => "1.0"
              }
            }
          EOF
          begin
            yield
          rescue Exception => e
            ::Chef::Log.warn(e.message)
            ::Chef::Log.warn(e.backtrace.inspect)
            return false
          end
        else
          return false
        end
        true
      end

      def tag_instance(action)
        adding = action == "add"

        rs_cli = adding ? "rs_tag -a #{rs_tag}" : "rs_tag -r #{rs_tag}"
        if right_link_tag_exists?
          right_link_tag rs_tag do
            action adding ? :publish : :remove
          end
        elsif `which rs_tag`
          `#{rs_cli}`
        else
          rest_tag_retval = run_rest_connection {
            instance = Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
            server = Server.find(:first) { |s| instance["href"].start_with? s.href }
            if adding
              Tag.set(server.current_instance_href, [rs_tag])
            else
              Tag.unset(server.current_instance_href, [rs_tag])
            end
          }
          if !rest_tag_retval
            ::Chef::Log.info("Not running on a RightScale server, and no RightScale API credentials were supplied. Skipping RightScale tag.")
          end
        end

        # TODO: Consider a mechanism that will work even in RightScale and Chef-Solo
        if (::Chef::VERSION && Gem::Version.new(::Chef::VERSION) >= Gem::Version.new('0.10.0'))
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
          ::Chef::Log.info("Chef version is older than 0.10.0, skipping Chef tag")
        end

        ec2_tag_it(action, instance_id)
      end

      def tag_volume(action)
        adding = action == "add"
        rest_tag_retval = run_rest_connection {
          vol = Ec2EbsVolume.find(:first) { |v| v.aws_id == new_resource.volume_id }
          if adding
            Tag.set(vol["href"], [rs_tag])
          else
            Tag.unset(vol["href"], [rs_tag])
          end
        }

        ec2_tag_it(action, new_resource.volume_id)
      end

      private

      def ec2_tag_it(action, resource_id)
        adding = action == "add"

        if node[:ec2] && new_resource.aws_access_key && new_resource.aws_secret_access_key
          if adding
            ec2.create_tags(resource_id, ec2_tag)
          else
            ec2.delete_tags(resource_id, ec2_tag)
          end
        elsif !new_resource.aws_access_key || !new_resource.aws_secret_access_key
          ::Chef::Log.info("Running on an Amazon EC2 instance, but no AWS credentials were provided, skipping EC2 tag.")
        else
          ::Chef::Log.info("Not running on an Amazon EC2 instance, skipping EC2 tag.")
        end
      end

    end
  end
end