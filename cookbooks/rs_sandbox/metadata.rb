maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures rs_sandbox"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

provides "rs_sandbox_exec(:code)"

recipe "rs_sandbox::default", "Sets up some useful bits for working with the RightScale sandbox in windows and *niz"