#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

define :ebs_conductor_attach_lineage,
    :lineage => nil,
    :aws_access_key_id => nil,
    :aws_secret_access_key => nil,
    :rs_email => nil,
    :rs_pass => nil,
    :rs_acct_num => nil,
    :device => nil,
    :vol_size_in_gb => nil,
    :snapshot_id => nil,
    :mountpoint => nil,
    :timeout => nil do

  include_recipe "ebs_conductor::default"

  # We know that fog is installed as a dependency of ebs_conductor, which is installed by including the default recipe above
  require 'rubygems'
  require 'fog'

  region = node[:ec2][:placement_availability_zone].gsub(/[a-z]*$/, '')
  fog = Fog::Compute.new({:region => region, :provider => 'AWS', :aws_access_key_id => params[:aws_access_key_id], :aws_secret_access_key => params[:aws_secret_access_key]})
  instance_id = node[:ec2][:instance_id]

  ::Chef::Log.info("Region - #{region}, fog - #{fog}, instance_id - #{instance_id}")

  current_volumes = fog.volumes.all('attachment.instance-id' => instance_id)
  attached_volumes_in_lineage = current_volumes.select {|vol| vol.tags.keys.include? "ebs_conductor:lineage=#{params[:lineage]}"}

  ::Chef::Log.info("attachedvols - #{attached_volumes_in_lineage}, attachedvols count - #{attached_volumes_in_lineage.count}")
  # TODO: This will have to change, and get smarter when/if we support striping
  # Could also be checking a node attribute rather than making an API call, but the API call is far more reliable, particularly since
  # a failed converge could leave the node attribute dirty and missing a record of an already attached volume/lineage
  if attached_volumes_in_lineage.count > 0
    ::Chef::Log.info("EBS Conductor lineage #{params[:lineage]} already attached to this instance as #{attached_volumes_in_lineage[0].id}")
  else
    device = params[:device]
    # If the device was not provided, we try to guess it
    unless device
      used_devices = current_volumes.collect {|vol| vol.device }
      available_devices = node[:ebs_conductor][:valid_ebs_devices] - used_devices
      device = available_devices[0]
    end

    # Capture the "before" list of drives and volumes in windows, so we can wait for the new drive to be added,
    # and know which volume to assign the drive letter to
    if node[:platform] == "windows"
      powershell "Get current disk and volume list" do
        ps_code = <<-EOF
# Clear out existing mount information, and disable automatic mounting. This allows us to mount a snapshot to a drive
# letter other than the one it was originally configured for on the same instance.  New instances will always get the
# specified drive letter because they have no previous knowledge of the volume id
mountvol /N
mountvol /R

$drives = Get-WMIObject Win32_DiskDrive
$device_ids = @()
foreach($drive in $drives)
{
  $device_ids += $drive.DeviceID
}
Set-ChefNode ebs_conductor_win32_disks -ArrayValue $device_ids

$volumes = Get-WMIObject Win32_Volume
$volume_ids = @()
foreach($volume in $volumes)
{
  $volume_ids += $volume.DeviceID
}
Set-ChefNode ebs_conductor_win32_volumes -ArrayValue $volume_ids
exit 0
        EOF
        source(ps_code)
      end
    end

    ruby_block "Debugz" do
      block do
        ::Chef::Log.info("Made it past execution of the first PS")
      end
    end

    ebs_conductor_volume params[:lineage] do
      lineage params[:lineage]
      aws_access_key_id params[:aws_access_key_id]
      aws_secret_access_key params[:aws_secret_access_key]
      rs_email params[:rs_email]
      rs_pass params[:rs_pass]
      rs_acct_num params[:rs_acct_num]
      device device
      size params[:vol_size_in_gb].to_i
      snapshot_id params[:snapshot_id]
      timeout params[:timeout]
      action [:attach]
    end

    if node[:platform] == "windows"
      powershell "Online, initialize, and format the drive" do
        parameters({"MOUNTPOINT" => params[:mountpoint]})
        ps_code = <<'EOF'
$drive_list = Get-ChefNode ebs_conductor_win32_disks
$volume_list = Get-ChefNode ebs_conductor_win32_volumes

$drives = Get-WMIObject Win32_DiskDrive
$device_ids = @()
foreach($drive in $drives)
{
  if($drive_list -notcontains $drive.DeviceID)
  {
    $device_ids += $drive.DeviceID
  }
}

Write-Output "Drive list before attach - $drive_list"
Write-Output "New drives after attach - $device_ids"

$volumes = Get-WMIObject Win32_Volume
$volume_ids = @()
foreach($volume in $volumes)
{
  if($volume_list -notcontains $volume.DeviceID)
  {
    $volume_ids += $volume.DeviceID
  }
}

Write-Output "Volume list before attach - $volume_list"
Write-Output "New volumes after attach - $volume_ids"

$letters = 68..89 | ForEach-Object { ([char]$_)+":" }
$freeletters = $letters | Where-Object {
  (New-Object System.IO.DriveInfo($_)).DriveType -eq 'NoRootDirectory'
}

$letter = $env:MOUNTPOINT
if (!$letter)
{
  $letter = $freeletters[0]
}

if($device_ids.count)
{
  $filter = 'DeviceID="'+$device_ids[0].replace("\", "\\")+'"'
  $drive = Get-WMIObject Win32_DiskDrive -filter $filter
  $script = $Null

  if ($drive) {
    Write-Output "New Drive ($device_ids[0]) detected."
    # Drive has no partitions, this is a new blank EBS vol
    if($drive.Partitions -eq "0")
    {
      $drivenumber = $drive.DeviceID -replace '[\\\\\.\\physicaldrive]',''
      $script = @"
select disk $drivenumber
clean
online disk noerr
attributes disk clear readonly noerr
create partition primary noerr
assign letter $letter noerr
format quick
"@

      Write-Output "Running diskpart with the following script"
      Write-Output $script
      $script | diskpart
    }
    elseif ($volume_ids.count)
    {
      $mountvolPath = $letter+":\"
      $message = "Mounting existing volume "+$device_ids[0]+" - "+$volume_ids[0]+" to $mountvolPath"
      Write-Output $message
      mountvol $mountvolPath $volume_ids[0]
    }
  }
}
EOF
        source(ps_code)
      end
    else
      bash "Format #{device} with XFS" do
        user "root"
        code <<-EOF
      grep -q xfs /proc/filesystems || modprobe xfs
      mkfs.xfs -q #{device}
        EOF
        not_if do
          params[:snapshot_id] or
          `file -s #{device} | grep XFS`.strip =~ /XFS/
        end
      end

      mount params[:mountpoint] do
        device device
        fstype "xfs"
        action [:mount, :enable]
      end
    end
  end
end