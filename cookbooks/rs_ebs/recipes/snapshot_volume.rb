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
include_recipe "skeme::default"

Chef::Log.info("Running rs_ebs::snapshot_volume")

skeme_tag_volume "foo:bar=baz" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  rs_email node[:rs_ebs][:rs_email]
  rs_pass node[:rs_ebs][:rs_pass]
  rs_acct_num node[:rs_ebs][:rs_acct_num]
  volume_id "volid"
  action :add
end