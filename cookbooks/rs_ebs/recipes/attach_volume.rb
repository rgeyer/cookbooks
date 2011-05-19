#
# Cookbook Name:: rs_ebs
# Recipe:: default
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

rjg_aws_ebs_volume "aio_ebs-#{node[:rjg_utils][:rs_instance_uuid]}" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  device "/dev/sdi"
  size node[:rjg_utils][:aio_ebs_size_in_gb].to_i
  if node[:rjg_utils][:aio_ebs_snapshot_id]
    snapshot_id node[:rjg_utils][:aio_ebs_snapshot_id]
  end
  action [:create, :attach]
end