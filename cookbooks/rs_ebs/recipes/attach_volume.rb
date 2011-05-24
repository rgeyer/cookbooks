#
# Cookbook Name:: rs_ebs
# Recipe:: attach_volume
#
# Copyright 2010, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "rs_ebs::default"

rs_ebs_attach_volume "Attach the specified EBS volume" do
  volume_name node[:rs_ebs][:volume_name]
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  device node[:rs_ebs][:device]
  vol_size_in_gb node[:rs_ebs][:vol_size_in_gb]
  snapshot_id node[:rs_ebs][:snapshot_id]
  mountpoint node[:rs_ebs][:mountpoint]
end