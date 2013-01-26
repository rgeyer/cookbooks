maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures utils"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rightscale_sandbox"

provides "rsa_keypair_from_pkcs12(:aws_access_key_id, :aws_secret_access_key, :s3_bucket, :s3_file, :pkcs12_pass, :rsa_cert_path, :rsa_key_path)"

recipe "utils::install_rest_connection_gem", "Installs version 0.0.15 of the rest_connection gem on either Windows or *nix"

attribute "utils/rest_pass",
  :display_name => "REST API Password",
  :description => "The password used to log into the RightScale dashboard, and the REST API",
  :recipes => ["utils::install_rest_connection_gem"],
  :required => "optional"

attribute "utils/rest_user",
  :display_name => "REST API Username",
  :description => "The email address used to log into the RightScale dashboard, and the REST API",
  :recipes => ["utils::install_rest_connection_gem"],
  :required => "optional"

attribute "utils/rest_acct_num",
  :display_name => "RightScale Account Number",
  :description => "Your RightScale account number",
  :recipes => ["utils::install_rest_connection_gem"],
  :required => "optional"