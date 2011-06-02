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

define :ebs_conductor_snapshot_lineage,
    :lineage => nil,
    :aws_access_key_id => nil,
    :aws_secret_access_key => nil,
    :rs_email => nil,
    :rs_pass => nil,
    :rs_acct_num => nil,
    :timeout => nil,
    :mountpoint => nil,
    :recipes_before => [],
    :recipes_after => [] do

  include_recipe "ebs_conductor::default"

  params[:recipes_before].each do |recipe_name|
    include_recipe recipe_name
  end

  # Freeze access to the device
  if node[:platform] == "windows"
    # TODO: Implement VSS freeze
  else
    bash "Freeze the xfs file system for #{params[:mountpoint]}" do
      code "xfs_freeze -f #{params[:mountpoint]}"
    end
  end

  ebs_conductor_volume params[:lineage] do
    lineage params[:lineage]
    aws_access_key_id params[:aws_access_key_id]
    aws_secret_access_key params[:aws_secret_access_key]
    rs_email params[:rs_email]
    rs_pass params[:rs_pass]
    rs_acct_num params[:rs_acct_num]
    timeout params[:timeout]
    action [:snapshot]
  end

  # Unfreeze access to the device
  if node[:platform] == "windows"
    # TODO: Implement VSS unfreeze
  else
    bash "Unfreeze the xfs file system for #{params[:mountpoint]}" do
      code "xfs_freeze -u #{params[:mountpoint]}"
    end
  end

  params[:recipes_after].each do |recipe_name|
    include_recipe recipe_name
  end

  ruby_block "Check for snapshot error" do
    block do
      if node[:ebs_conductor_snapshot_error]
        message = <<-EOF
ebs_conductor failed to create a snapshot. Execution continued so that services and volumes could be unfrozen, but no snapshot was created.  The error was as follows.

#{node[:ebs_conductor_snapshot_error]}
EOF
        raise message
      end
    end
  end

end