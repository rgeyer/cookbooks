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

actions [:add, :delete]

attribute :tag_namespace, :kind_of => [String], :required => true
attribute :tag_predicate, :kind_of => [String], :required => true
attribute :tag_value,     :kind_of => [String], :required => true

attribute :tag, :kind_of => [String], :required => true, :name_attribute => true
attribute :ec2_tag, :kind_of => [String]
attribute :rs_tag, :kind_of => [String]

attribute :aws_access_key, :kind_of => [String]
attribute :aws_secret_access_key, :kind_of => [String]

attribute :rs_email, :kind_of => [String]
attribute :rs_pass, :kind_of => [String]
attribute :rs_acct_num, :kind_of => [String]