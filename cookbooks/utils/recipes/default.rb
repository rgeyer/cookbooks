#
# Cookbook Name:: utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

`LocateSandbox.bat`
`SET PATH=%RS_SANDBOX_PATH%\Ruby\bin;%PATH%`

Chef::Log.info(`gem list`)