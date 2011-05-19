maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures rs_ebs"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rjg_aws"

supports "ubuntu"
supports "windows"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "required"