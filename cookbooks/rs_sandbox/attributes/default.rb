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

default[:rs_sandbox][:home] = "/opt/rightscale/sandbox/"
default[:rs_sandbox][:gem_bin] = "/opt/rightscale/sandbox/bin/gem"
# TODO: Haven't found a use for this in Linux yet, nor have I found an elegant way to find it. Check the
# default recipe to see how I'm setting this for windows.
default[:rs_sandbox][:rl_user_home_dir] = nil