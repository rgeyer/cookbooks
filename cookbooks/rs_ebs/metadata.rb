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

attribute "rs_ebs/volume_name",
  :display_name => "RS_EBS Volume Name",
  :description => "A unique volume name.  If no name is supplied the volume name will be <ec2-instance-id>_<device>",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "optional"

attribute "rs_ebs/device",
  :display_name => "RS_EBS Volume Device",
  :description => "The desired device for the new EBS volume.  On Windows this is xvd[b-p], on linux this is /dev/sd[a-p][1-15].  If no device is supplied, the next available one will be automatically chosen",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "optional"

attribute "rs_ebs/vol_size_in_gb",
  :display_name => "RS_EBS Volume Size in GB",
  :description => "The desired volume size, measured in GB",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "required"

attribute "rs_ebs/snapshot_id",
  :display_name => "RS_EBS Volume Snapshot Id",
  :description => "The full AWS id of a snapshot which will be used to create the volume.  This is used to launch a new server instance with the state stored in the specified snapshot.  If left blank a new EBS volume is created.",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "optional"

attribute "rs_ebs/mountpoint",
  :display_name => "RS_EBS Volume Mountpoint",
  :description => "The path where the new EBS volume will be mounted. For windows this is simply a drive letter designation, on linux any path is acceptable.",
  :recipes => ["rs_ebs::attach_volume"],
  :required => "required"