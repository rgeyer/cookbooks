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

def load_ruby_gem_into_rs_sandbox(gem_name, gem_version=nil, gem_source=nil, require_gem_after_install=false)
  if node[:platform] == "windows"
    # NOTE: For Windows, this installs the rest_connection config yaml file only for the RightScale_1 user, so if you try
    # to use it for other stuff like, say a scheduled windows task that runs as administrator, you'd be hosed.

    # TODO: I should be able do this like so.. Only it doesn't work in windows, even on the latest chef (0.9.8). RightScale sandbox runs chef (0.8.x)
    # This would be cross platform compatible if it worked though..
    # http://tickets.opscode.com/browse/CHEF-1682

#    g = gem_package gem_name do
#      if gem_version
#        version gem_version
#      end
#      if gem_source
#        source gem_source
#      end
#      gem_binary node[:rs_sandbox][:gem_bin]
#      action :nothing
#    end
#
#    g.run_action(:install) if ::File.exists? node[:rs_sandbox][:gem_bin]

    gem_already_installed = `#{node[:rs_sandbox][:gem_bin]} list | findstr "#{gem_name}"`

    if gem_already_installed.strip == ""
      Chef::Log.info("Installing #{gem_name} #{gem_version} gem in the RightScale sandbox")
      install_params = "install --both --no-rdoc --no-force --no-test --no-ri"
      install_params += " --version '#{gem_version}'" if gem_version
      install_params += " --source '#{gem_source}'" if gem_source
      install_params += " #{gem_name}"
      `#{node[:rs_sandbox][:gem_bin]} #{install_params}`
    end
  else
    # TODO: Per the above TODO, this should be all that is necessary, once Chef is fixed.
    # http://tickets.opscode.com/browse/CHEF-1682

    # Installs for the RightScale sandbox (in linux)
    g = gem_package gem_name do
      if gem_version
        version gem_version
      end
      if gem_source
        source gem_source
      end
      gem_binary node[:rs_sandbox][:gem_bin]
      action :nothing
    end

    g.run_action(:install) if ::File.exists? node[:rs_sandbox][:gem_bin]
  end

  Gem.clear_paths
  require gem_name if require_gem_after_install
end