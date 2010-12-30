#
# Cookbook Name:: ruby_gems
# Recipe:: default
#
# Copyright 2010, Ryan J. Geyer
#
# All rights reserved - Do Not Redistribute
#

if node[:platform] == 'windows'
  rs_sandbox_exec "Add http://rubygems.org to gem sources for RightScale sandbox" do
    code <<-EOF
if (!(cmd /c gem sources --list | findstr 'http://rubygems.org')) {
  cmd /c gem sources --add 'http://rubygems.org'
}

write-output("Yeah, I did that.. Yo..")
    EOF
  end
#  powershell "Add http://rubygems.org to gem sources for RightScale sandbox" do
#    powershell_script = <<'EOF'
## Make sure we know where to find the sandbox
#cmd /c LocateSandBox.bat
#
## Modify the path environment variable for just this powershell execution, so we can find
## things like gem, and ruby..
#[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:RS_RUBY_HOME\bin;$env:RS_SANDBOX_HOME\bin\windows;$env:RS_SANDBOX_HOME\right_link\scripts\windows")
#
#if (!(cmd /c gem sources --list | findstr 'http://rubygems.org')) {
#  cmd /c gem sources --add 'http://rubygems.org'
#}
#EOF
#    source(powershell_script)
#  end
else
  include_recipe "rubygems::default"
end