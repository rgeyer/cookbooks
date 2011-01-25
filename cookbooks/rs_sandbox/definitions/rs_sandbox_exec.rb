define :rs_sandbox_exec, :code => "" do
  if node[:platform] == "windows"
  powershell_script = <<'EOF'
# Make sure we know where to find the sandbox
cmd /c LocateSandBox.bat

# Modify the path environment variable for just this powershell execution, so we can find
# things like gem, and ruby..
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:RS_SANDBOX_HOME\Ruby\bin;$env:RS_SANDBOX_HOME\bin\windows;$env:RS_SANDBOX_HOME\right_link\scripts\windows")

EOF

  powershell_script += params[:code]

  powershell params[:name] do
    source(powershell_script)
  end
  else
  # TODO: Technically, this doesn't do anything that's specific to the sandbox, I need to add a chroot to make this really useful
    bash do
      code params[:code]
    end
  end

end