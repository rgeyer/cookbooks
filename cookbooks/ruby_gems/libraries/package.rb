def load_ruby_gem_into_rs_sandbox(gem_name, gem_version=nil, gem_source=nil)
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

    gem_already_installed = `#{node[:rs_sandbox][:gem_bin]} list | findstr '#{gem_name}'`

    if gem_already_installed.strip == ""
      install_params = "install --both --no-rdoc --no-force --no-test --no-ri --ignore-dependencies"
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
end