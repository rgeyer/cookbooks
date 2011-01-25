#
# Cookbook Name:: utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

`SETX PATH %RS_SANDBOX_HOME%\\Ruby\\bin` unless `echo %RS_SANDBOX_HOME%` =~ /Ruby\\bin/

Chef::Log.info(`gem.bat list`)