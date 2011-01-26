include RGeyer::Aws::S3

action :get do
  s3_file=new_resource.s3_file

  if(new_resource.s3_file_prefix)
    file_list = s3.bucket(new_resource.s3_bucket).keys('prefix' => new_resource.s3_file_prefix).sort {|x,y| x.name <=> y.name}
    latest_file = file_list.last
    s3_file = latest_file
  end

  fq_filepath = new_resource.file_path

  Chef::Log.info("Downloading #{new_resource.s3_bucket}:#{s3_file.name} to #{fq_filepath}")

  file = ::File.open(fq_filepath, 'w')
  s3.interface.get(new_resource.s3_bucket, s3_file.name) { |chunk|
    file.write(chunk)
  }
  file.close()
end

action :put do
  s3_bucket = s3.bucket(new_resource.s3_bucket)
  s3_filekey = new_resource.s3_file
  s3_file_prefix = new_resource.s3_file_prefix
  s3_file_ext = new_resource.s3_file_extension
  history_to_keep = new_resource.history_to_keep
  file_path = new_resource.file_path

  if s3_file_prefix
    datestring = Time.now.strftime("%Y%m%d%H%M")
    s3_filekey = "#{s3_file_prefix}-#{datestring}#{s3_file_ext}"
  end

  Chef::Log.info("Uploading #{file_path} to S3 at #{s3_bucket}:#{s3_filekey}")

  s3.interface.put(s3_bucket, s3_filekey, ::File.open(file_path, 'r'))

  if history_to_keep && s3_file_prefix
    file_list = s3_bucket.keys('prefix' => s3_file_prefix).sort {|x,y| x.name <=> y.name}
    num_to_delete = file_list.size - history_to_keep
    Chef::Log.info("Deleting #{num_to_delete} files with the prefix #{s3_file_prefix}.") if num_to_delete > 0
    file_list.each_with_index {|file,idx|
      if idx == num_to_delete then break end
      file.delete
      Chef::Log.info("Deleted #{s3_bucket}:#{file.name} from S3")
    } if file_list.size > history_to_keep
  end
end