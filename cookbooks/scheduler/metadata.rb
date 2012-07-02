maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures scheduler"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

%w{centos ubuntu windows}.each do |os|
  supports os
end

depends "rightscale"

recipe "scheduler::setup_scheduler", "Creates the hourly and daily scheduler jobs based on the inputs"
recipe "scheduler::do_list_jobs", "Lists all scheduled jobs"

attribute "scheduler/username",
  :display_name => "Scheduler Admin Username",
  :description => "The username for the user that will be used to run scheduled tasks in windows only.  This can be excluded on *nix OS's",
  :recipes => ["scheduler::setup_scheduler"]

attribute "scheduler/password",
  :display_name => "Scheduler Admin Password",
  :description => "The password for the user that will be used to run scheduled tasks in windows only.  This can be excluded on *nix OS's",
  :recipes => ["scheduler::setup_scheduler"]

attribute "scheduler/daily_time",
  :display_name => "Scheduler Daily Time",
  :description => "The time of the day, based on the server's timezone, to run the daily scheduled tasks. Format: hh:mm (e.g., 22:30)",
  :recipes => ["scheduler::setup_scheduler"],
  :required => "required"