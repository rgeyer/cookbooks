maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "monkeypatches to fake databags functionality in Chef Solo/RightScale"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "databags::default", "Lists all available databags"