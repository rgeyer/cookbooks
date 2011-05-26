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

define :rs_ebs_attach_volume,
    :volume_name => nil,
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
    :timeout => 300 do
  # TODO: Tag the device with some lineage and what not

  require 'rubygems'
  require 'right_aws'

  ec2 = RightAws::Ec2.new(params[:aws_access_key_id], params[:aws_secret_access_key], { :logger => Chef::Log })
  instance_id = node[:ec2][:instance_id]

  device = params[:device]
  # If the device was not provided, we try to guess it
  # Also, note that this is dependent upon Right_AWS <= 2.0 later versions change the signature of the describe_volumes method.
  unless device
    devices_for_instance = ec2.describe_volumes.select{|vol| vol[:aws_instance_id] == instance_id}
    used_devices = devices_for_instance.collect {|vol| vol[:aws_device] }
    available_devices = node[:rs_ebs][:valid_ebs_devices] - used_devices
    device = available_devices[0]
  end

  volname = params[:volume_name] || "#{instance_id}_#{device}"

  include_recipe "rs_ebs::default"
  include_recipe "skeme::default"

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
Set-ChefNode rs_ebs_win32_disks -ArrayValue $device_ids

$volumes = Get-WMIObject Win32_Volume
$volume_ids = @()
foreach($volume in $volumes)
{
  $volume_ids += $volume.DeviceID
}
Set-ChefNode rs_ebs_win32_volumes -ArrayValue $volume_ids
      EOF
      source(ps_code)
    end
  end

  rjg_aws_ebs_volume volname do
    aws_access_key params[:aws_access_key_id]
    aws_secret_access_key params[:aws_secret_access_key]
    device device
    size params[:vol_size_in_gb].to_i
    if params[:snapshot_id]
      snapshot_id params[:snapshot_id]
    end
    action [:create, :attach]
  end

  skeme_tag_volume "rs_ebs:lineage=#{params[:lineage]}" do
    aws_access_key params[:aws_access_key_id]
    aws_secret_access_key params[:aws_secret_access_key]
    rs_email params[:rs_email]
    rs_pass params[:rs_pass]
    rs_acct_num params[:rs_acct_num]
    volume_id { node[:aws][:ebs_volume][volname][:volume_id] }
    action :add
  end

  if node[:platform] == "windows"
    # TODO: This is a total hack, but if I don't do it, mounting later fails when I'm attaching
    # a new volume from a snapshot.  Probably a symptom of another problem but this seems to fix it.
    powershell "Wait for #{device}" do
      parameters({'TIMEOUT' => params[:timeout]})
      ps_code = <<-EOF
$drive_list = Get-ChefNode rs_ebs_win32_disks
$start_ts = [DateTime]::Now
do
{
  Start-Sleep -s 2
  $drives = Get-WMIObject Win32_DiskDrive
}
while (($drive_list.count -eq $drives.count) -and (([DateTime]::Now - $start_ts) -lt $env:TIMEOUT))
if(([DateTime]::Now - $start_ts) -gt $env:TIMEOUT)
{
  Write-Error "Timeout of $env:TIMEOUT seconds reached while waiting for volume attachment"
}
      EOF

      source(ps_code)
    end

    powershell "Online, initialize, and format the drive" do
      parameters({"MOUNTPOINT" => params[:mountpoint]})
      # TODO: Don't format the drive if it's already formatted, as in the
      # case of attaching a snapshot
      ps_code = <<'EOF'
$drive_list = Get-ChefNode rs_ebs_win32_disks
$volume_list = Get-ChefNode rs_ebs_win32_volumes

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
online disk noerr
attributes disk clear readonly noerr
create partition primary noerr
format quick
assign letter $letter noerr
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
    # TODO: This is a total hack, but if I don't do it, mounting later fails when I'm attaching
    # a new volume from a snapshot.  Probably a symptom of another problem but this seems to fix it.
    ruby_block "Wait for #{device}" do
      block do
        start_ts = Time.now.to_i
        while !::File.exist?('/dev/sdi') && (Time.now.to_i - start_ts) < params[:timeout] do
          sleep(2)
        end
        if (Time.now.to_i - start_ts) > params[:timeout]
          raise "Timeout of #{params[:timeout]} seconds reached while waiting for volume attachment"
        end
      end
    end

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