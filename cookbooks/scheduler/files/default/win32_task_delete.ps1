# Copyright (c) 2010 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# locals.
$name = $env:NAME

# "Stop" or "Continue" the powershell script execution when a command fails
$ErrorActionPreference = "Stop"

#check inputs.
$Error.Clear()
if (($name -eq $NULL) -or ($name -eq ""))
{
    Write-Error "Error: 'name' is a required attribute for the 'scheduled_tasks' provider. Aborting..."
    exit 140
}

#remove any characters that might brake the command
$name = $name -replace '[^\w]', ''

schtasks.exe /delete /F /TN $name

if (!$?)
{
    Write-Error "Error: SCHTASKS execution failed."
    exit 141
}
