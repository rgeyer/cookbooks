#
# Cookbook Name:: utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

`LocateSandbox.bat`
Chef::Log.info(`echo %RS_SANDBOX_PATH%`)
`SET PATH=%RS_SANDBOX_PATH%\Ruby\bin;%PATH%`
Chef::Log.info(`echo %PATH%`)
