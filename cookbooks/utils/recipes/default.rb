#
# Cookbook Name:: utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

gem_path=`echo %RS_SANDBOX_HOME%`.strip
gem_path+="\\Ruby\\bin\\gem.bat"

Chef::Log.info(`#{gem_path} list`)