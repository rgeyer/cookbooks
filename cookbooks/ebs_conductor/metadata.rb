maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures ebs_conductor"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.3"

supports "ubuntu"
supports "windows"

depends "rs_sandbox"
depends "scheduler"

recipe "ebs_conductor::default", "Installs the EBS Conductor gem and any platform specific packages"
recipe "ebs_conductor::aio_lineage", "Attaches a volume for the specified lineage at the first available device"
recipe "ebs_conductor::aio_lineage_snapshot", "Snapshots the specified lineage"
recipe "ebs_conductor::aio_lineage_enable_continuous_backup", "Schedules a daily snapshot of the AIO lineage. Requires that scheduler has been configured by running scheduler::default"
recipe "ebs_conductor::aio_lineage_disable_continuous_backup", "Unschedules the daily snapshot of the AIO lineage. Requires that scheduler has been configured by running scheduler::default"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot","ebs_conductor::default"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot","ebs_conductor::default"],
  :required => "required"

attribute "ebs_conductor/aio_lineage",
  :display_name => "EBS Conductor AIO Lineage",
  :description => "A name which uniquely identifies a lineage of EBS volumes snapshots.  The name must be unique within an AWS account!",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot"],
  :required => "required"

attribute "ebs_conductor/aio_vol_size_in_gb",
  :display_name => "EBS Conductor AIO Volume Size in GB",
  :description => "The desired volume size, measured in GB",
  :recipes => ["ebs_conductor::aio_lineage"],
  :required => "required"

attribute "ebs_conductor/aio_snapshot_id",
  :display_name => "EBS Conductor AIO Volume Snapshot Id",
  :description => "An optional snapshot id. If provided a volume will be attached and assigned to the lineage. This is useful for selecting an older snapshot from the same lineage, or choosing to start a new lineage from an old lineage, or starting a new lineage from a \"naked\" snapshot with no lineage",
  :recipes => ["ebs_conductor::aio_lineage"],
  :required => "optional"

attribute "ebs_conductor/aio_mountpoint",
  :display_name => "EBS Conductor AIO Volume Mountpoint",
  :description => "The path where the new lineage will be mounted. For windows this is simply a drive letter designation, on linux any path is acceptable.",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot"],
  :required => "required"

attribute "ebs_conductor/aio_history_to_keep",
  :display_name => "EBS Conductor AIO History to Keep",
  :description => "The number of snapshots to be kept for the lineage.  Old snapshots in excess of aio_history_to_keep will be deleted.  If left blank snapshots will never be deleted.",
  :recipes => ["ebs_conductor::aio_lineage_snapshot"],
  :required => "optional"

attribute "ebs_conductor/rs_email",
  :display_name => "RightScale Account Email",
  :description => "The email address of a RightScale user who has permissions to tag instances, volumes, and snapshots",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot"],
  :required => "optional"

attribute "ebs_conductor/rs_pass",
  :display_name => "RightScale Account Password",
  :description => "The password of a RightScale user who has permissions to tag instances, volumes, and snapshots",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot"],
  :required => "optional"

attribute "ebs_conductor/rs_acct_num",
  :display_name => "RightScale Account Number",
  :description => "The RightScale account number",
  :recipes => ["ebs_conductor::aio_lineage","ebs_conductor::aio_lineage_snapshot"],
  :required => "optional"

attribute "ebs_conductor/aio_snapshot_recipes_before",
  :display_name => "EBS Conductor AIO Before Snapshot Recipes",
  :description => "A comma seperated list of recipes which will be run before the AIO volume is frozen and a snapshot is taken.  This is useful for any services which may require more preparation than a simple write freeze of the volume",
  :type => "array",
  :required => "optional",
  :recipes => ["ebs_conductor::aio_lineage_snapshot"]

attribute "ebs_conductor/aio_snapshot_recipes_after",
  :display_name => "EBS Conductor AIO After Snapshot Recipes",
  :description => "A comma seperated list of recipes which will be run after the AIO volume is frozen and a snapshot is taken.  This is useful for any restoring any services stopped/prepared by ebs_conductor/aio_snapshot_recipes_before",
  :type => "array",
  :required => "optional",
  :recipes => ["ebs_conductor::aio_lineage_snapshot"]