maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures scheduler"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{centos ubuntu windows}.each do |os|
  supports os
end

recipe "scheduler::default", "Creates the hourly and daily scheduler jobs based on the inputs"

attribute "scheduler/username",
  :display_name => "Scheduler Admin Username",
  :description => "The username for the user that will be used to run scheduled tasks in windows only.  This can be excluded on *nix OS's",
  :recipes => ["scheduler::default"]

attribute "scheduler/password",
  :display_name => "Scheduler Admin Password",
  :description => "The password for the user that will be used to run scheduled tasks in windows only.  This can be excluded on *nix OS's",
  :recipes => ["scheduler::default"]

attribute "scheduler/daily_time",
  :display_name => "Scheduler Daily Time",
  :description => "The time of the day, based on the server's timezone, to run the daily scheduled tasks. Format: hh:mm (e.g., 22:30)",
  :recipes => ["scheduler::default"],
  :required => "required"