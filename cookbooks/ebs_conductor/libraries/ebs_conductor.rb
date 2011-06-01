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
  require 'ebs_conductor'
rescue LoadError
  Chef::Log.warn("ebs_conductor gem not installed, try running the ebs_conductor::default recipe to install it.")
end

module Rgeyer
  module Chef
    module EbsConductor
      def ebs_conductor
        @@ebs_conductor ||= Rgeyer::Gem::EbsConductor.new(new_resource.aws_access_key_id, new_resource.aws_secret_access_key,
          {
            :rs_email => new_resource.rs_email,
            :rs_pass => new_resource.rs_pass,
            :rs_acct_num => new_resource.rs_acct_num,
            :logger => ::Chef::Log
          }
        )
      end
    end
  end
end