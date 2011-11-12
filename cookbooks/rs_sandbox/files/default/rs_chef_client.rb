#!/opt/rightscale/sandbox/bin/ruby
require 'rubygems'
require 'yaml'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'right_link_config'))
require 'eventmachine'
require 'chef'
require 'chef/application/solo'
require 'chef/knife'
require 'fileutils'
require 'right_scraper'

BASE_DIR = File.join(File.dirname(__FILE__), '..')

require File.normalize_path(File.join(BASE_DIR, 'agents', 'lib', 'instance'))
require File.normalize_path(File.join(BASE_DIR, 'agents', 'lib', 'instance', 'cook'))
require File.normalize_path(File.join(BASE_DIR, 'chef', 'lib', 'providers'))

ObjectSpace.each_object(Class) {|c| puts c }

Chef::Config.from_file("/etc/chef/client.rb")
#c = Chef::Client.new
#c.config[:yes] = true
#c.run

#Chef::Application::Solo.new.run