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

define :rsa_keypair_from_pkcs12, :aws_access_key_id => nil, :aws_secret_access_key => nil, :s3_bucket => nil, :s3_file => nil, :pkcs12_pass => nil, :rsa_cert_path => nil, :rsa_key_path => nil do
  tempdir = "/tmp/pkcs12"
  pkcs12_cert="#{tempdir}/cert.pkcs12"
  rsa_pair = "#{tempdir}/rsa_pair.crt"

  directory tempdir do
    recursive true
    action :create
  end

  rjg_aws_s3 "Get the PKCS12 file" do
    access_key_id params[:aws_access_key_id]
    secret_access_key params[:aws_secret_access_key]
    s3_bucket params[:s3_bucket]
    s3_file params[:s3_file]
    file_path pkcs12_cert
    action :get
  end

  bash "Convert PKCS12 to RSA Pair" do
    code <<-EOF
openssl pkcs12 -passin pass:#{params[:pkcs12_pass]} -in #{pkcs12_cert} -out #{rsa_pair} -nodes
    EOF
  end

  ruby_block "Extract pair from converted file" do
    block do
      copy_to_key = false
      copy_to_cert = false
      key = ''
      cert = ''
      ::File.new(rsa_pair, 'r').each_line do |line|
        if line =~ /-----BEGIN RSA PRIVATE KEY-----/
          key = line
          copy_to_key = true
          next
        end
        if copy_to_key
          key += line
          if line =~ /-----END RSA PRIVATE KEY-----/ then
            copy_to_key = false
          end
        end
        if line =~ /-----BEGIN CERTIFICATE-----/
          cert = line
          copy_to_cert = true
          next
        end
        if copy_to_cert
          cert += line
          if line =~ /-----END CERTIFICATE-----/ then
            copy_to_cert = false
          end
        end
      end
      ::File.open(params[:rsa_cert_path], 'w') { |cert_file| cert_file.write(cert) }
      ::File.open(params[:rsa_key_path], 'w') { |key_file| key_file.write(key) }
    end
    notifies :delete, resources(:directory => tempdir), :immediately
  end
end