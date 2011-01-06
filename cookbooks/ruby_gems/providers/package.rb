action :install do
  install_command = "install --both --no-rdoc --no-force --no-test -y"
  install_command += " --version '#{new_resource.version}'" if new_resource.version
  install_command += " #{new_resource.name}"
  if node[:platform] == "windows"
    # NOTE: For Windows, this installs the rest_connection config yaml file only for the RightScale_1 user, so if you try
    # to use it for other stuff like, say a scheduled windows task that runs as administrator, you'd be hosed.

    rs_sandbox_exec "Install rest_connection gem" do
      code <<-EOF
cmd /c gem #{install_command}
      EOF
    end
  else
    # Installs for the actual server environment
    gem_package new_resource.name do
      if new_resource.version
        version new_resource.version
      end
      action :install
    end

    # Installs for the RightScale sandbox
    bash "Installing #{new_resource.name} ruby gem in RightScale sandbox" do
      code <<-EOF
/opt/rightscale/sandbox/bin/gem #{install_command}
      EOF
      not_if "/opt/rightscale/sandbox/bin/gem list | grep #{new_resource.name}"
    end
  end
end