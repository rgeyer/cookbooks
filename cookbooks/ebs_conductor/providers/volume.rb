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

include Rgeyer::Chef::EbsConductor

action :attach do
  options = {}
  options[:timeout] = new_resource.timeout if new_resource.timeout
  options[:snapshot_id] = new_resource.snapshot_id if new_resource.snapshot_id
  ::Chef::Log.info("options was #{options}, about to call the gem")
  ebs_conductor.attach_from_lineage(
    node[:ec2][:instance_id], new_resource.lineage, new_resource.size, new_resource.device, options
  )
  ::Chef::Log.info("Gem called yo")
end

action :snapshot do
  options = {}
  options[:timeout] = new_resource.timeout if new_resource.timeout
  options[:history_to_keep] = new_resource.history_to_keep if new_resource.history_to_keep
  node[:ebs_conductor_snapshot_error] = nil
  begin
    ebs_conductor.snapshot_lineage(new_resource.lineage, options)
  rescue Object => o
    node[:ebs_conductor_snapshot_error] = o
  end
end