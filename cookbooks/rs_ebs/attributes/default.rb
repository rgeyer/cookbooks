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

if node[:platform] == "windows"
  device_list_ary = []
  ("b".."p").each do |letter|
    device_list_ary << "xvd#{letter}"
  end
  default[:rs_ebs][:valid_ebs_devices] = device_list_ary
else
  device_list_ary = []
  ("a".."p").each do |letter|
    (1..15).each do |number|
      device_list_ary << "/dev/sd#{letter}#{number}"
    end
  end
  default[:rs_ebs][:valid_ebs_devices] = device_list_ary
end