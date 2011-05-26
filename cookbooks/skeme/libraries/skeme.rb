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
  require 'skeme'
rescue LoadError
  Chef::Log.warn("Skeme gem is not installed.  Please run skeme::default and try again.")
end

module Rgeyer
  module Chef
    module Skeme

      def skeme_gem
        @@skeme_gem ||= ::Skeme::Skeme.new({
          :aws_access_key_id => new_resource.aws_access_key_id,
          :aws_secret_access_key => new_resource.aws_secret_access_key,
          :rs_email => new_resource.rs_email,
          :rs_pass => new_resource.rs_pass,
          :rs_acct_num => new_resource.rs_acct_num,
          :logger => Chef::Log.new
        })
      end

      def tag
        @@tag ||= new_resource.name
      end

      def ec2_tag
        @@ec2_tag = new_resource.ec2_tag || tag
      end

      def rs_tag
        @@rs_tag = new_resource.rs_tag || tag
      end

      def instance_id
        @@instance_id ||= query_instance_id
      end

      def tag_instance(action)
        adding = action == "add"

        # Check if we're running on an instance and only use the gem in the worst case scenario
        rs_cli = adding ? "rs_tag -a #{rs_tag}" : "rs_tag -r #{rs_tag}"
        if right_link_tag_exists?
          tag_action = adding ? :publish : :remove
          right_link_tag rs_tag do
            action tag_action
          end
        elsif `which rs_tag`
          # TODO: "which" does not exist on windows, that could get tricky...
          `#{rs_cli}`
        end

        if adding
          skeme_gem.set_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_instance_id => instance_id
          })
        else
          skeme_gem.unset_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_instance_id => instance_id
          })
        end
      end

      def tag_volume(action)
        adding = action == "add"
        if adding
          skeme_gem.set_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_ebs_volume_id => new_resource.volume_id
          })
        else
          skeme_gem.unset_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_ebs_volume_id => new_resource.volume_id
          })
        end
      end

      def tag_snapshot(action)
        adding = action == "add"
        if adding
          skeme_gem.set_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_ebs_snapshot_id => new_resource.snapshot_id
          })
        else
          skeme_gem.unset_tag({
            :tag => tag,
            :ec2_tag => ec2_tag,
            :rs_tag => rs_tag,
            :ec2_ebs_snapshot_id => new_resource.snapshot_id
          })
        end
      end

      private

      def right_link_tag_exists?
        klass = Module.const_get("Chef::Provider::RightLinkTag")
        return klass.is_a?(Class)
      rescue NameError
        return false
      end

      def query_instance_id
        instance_id = open('http://169.254.169.254/latest/meta-data/instance-id'){|f| f.gets}
        raise "Cannot find instance id!" unless instance_id
        Chef::Log.debug("Instance ID is #{instance_id}")
        instance_id
      end
    end
  end
end