#
# Cookbook Name:: aws
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "rs_sandbox::default"

load_ruby_gem_into_rs_sandbox("right_aws", nil, nil, true)