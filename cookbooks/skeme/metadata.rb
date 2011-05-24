maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures skeme"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.3"

depends "rjg_aws"

provides "skeme_tag[add]"
provides "skeme_tag[delete]"

provides "skeme_tag_volume[add]"
provides "skeme_tag_volume[delete]"

#provides "skeme_tag_snapshot[add]"
#provides "skeme_tag_snapshot[delete]"