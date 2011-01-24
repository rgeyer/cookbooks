action :install do
  install_command = "install --both --no-rdoc --no-force --no-test --no-ri --ignore-dependencies"
  install_command += " --version '#{new_resource.version}'" if new_resource.version
  install_command += " --source '#{new_resource.source}'" if new_resource.source
  install_command += " #{new_resource.name}"
  if node[:platform] == "windows"
    # NOTE: For Windows, this installs the rest_connection config yaml file only for the RightScale_1 user, so if you try
    # to use it for other stuff like, say a scheduled windows task that runs as administrator, you'd be hosed.

    a = rs_sandbox_exec "Install rest_connection gem" do
      code <<-EOF
cmd /c gem #{install_command}
      EOF
    end

    a.run_action(:install)

  else
    # Installs for the servers system environment
    b = gem_package new_resource.name do
      if new_resource.version
        version new_resource.version
      end
      if new_resource.source
        source new_resource.source
      end
      action :install
    end

    # Installs for the RightScale sandbox
    c = gem_package new_resource.name do
      if new_resource.version
        version new_resource.version
      end
      if new_resource.source
        source new_resource.source
      end
      gem_binary "/opt/rightscale/sandbox/bin/gem"
      action :install
    end
  end

  b.run_action(:install)
  c.run_action(:install)

  Gem.clear_paths
end