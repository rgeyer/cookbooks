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