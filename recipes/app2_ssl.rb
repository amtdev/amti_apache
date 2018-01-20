#
# Cookbook:: amti_apache
# Recipe:: app2_ssl
#
# Copyright:: 2018, Advanced Marketing Training, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

template "/etc/apache2/sites-available/111-" + node['app2']['server_name'] + "-ssl.conf" do
  source 'site.conf.ssl.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables(
    :docroot        	 =>  node['app2']['path'] + "/" + node['app2']['project_dir'] + "/" + node['app2']['public_dir'],
    :server_port        	 => "443",
    :server_name     => node["app2"]["server_name"],
    :server_alias      => node["app2"]["server_alias"],
    :cert_name  =>  node["app2"]["cert_name"],
    :key_name  =>  node["app2"]["key_name"],
    :directory_options        	 => "Indexes FollowSymLinks",
    :allow_override        	 => "All")
end

execute "enable site" do
  command "sudo a2ensite 111-" + node['app2']['server_name'] + "-ssl.conf"
end

service "apache2" do
  action :restart
end