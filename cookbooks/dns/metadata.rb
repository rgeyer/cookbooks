maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "A chef library for updating DNS records in (AWS,DNSMadeEasy,...)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rs_sandbox"

conflicts "ebs_conductor", "0.0.2"
conflicts "skeme", "0.0.4"

recipe "dns::default", "Installs the fog gem version ~> 0.9.0"