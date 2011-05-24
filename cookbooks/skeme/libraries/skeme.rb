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

module Rgeyer
  module Chef
    module Skeme
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
          @@logger ||= Logger.new(::Chef::Log)
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
          @@logger ||= Logger.new(::Chef::Log)
          EOF
          begin
            yield
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
            return false
          end
        else
          return false
        end

        true
      end
    end
  end
end