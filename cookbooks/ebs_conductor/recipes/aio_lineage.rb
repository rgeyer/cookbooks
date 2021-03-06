#
# Cookbook Name:: ebs_conductor
# Recipe:: aio_volume
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

include_recipe "ebs_conductor::default"

ebs_conductor_attach_lineage "Attach AIO lineage #{node[:ebs_conductor][:aio_lineage]}" do
  lineage node[:ebs_conductor][:aio_lineage]
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  rs_email node[:ebs_conductor][:rs_email]
  rs_pass node[:ebs_conductor][:rs_pass]
  rs_acct_num node[:ebs_conductor][:rs_acct_num]
  vol_size_in_gb node[:ebs_conductor][:aio_vol_size_in_gb]
  if node[:ebs_conductor][:aio_snapshot_id]
    snapshot_id node[:ebs_conductor][:aio_snapshot_id]
  end
  mountpoint node[:ebs_conductor][:aio_mountpoint]
end