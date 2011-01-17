maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures ruby_gems"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

# I'm hesitant to actually include depends statements here, since the dependencies will differ based on the platform
# and which RepoPath this repo/cookbook is a part of
# depends "rubygems"
# depends "rs_sandbox"

depends "rubygems"

provides "ruby_gems[package]"

recipe "ruby_gems::default","Adds http://rubygems.org to the gem sources list"