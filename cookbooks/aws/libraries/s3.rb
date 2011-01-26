begin
  require 'right_aws'
rescue LoadError
  Chef::Log.warn("Missing gem 'right_aws', make sure to run aws::default")
end

module RGeyer
  module Aws
    module S3
      def s3
        @@s3 ||= RightAws::S3.new(new_resource.access_key_id, new_resource.secret_access_key, { :logger => Chef::Log })
      end
    end
  end
end