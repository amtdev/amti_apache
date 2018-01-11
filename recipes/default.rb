#
# Cookbook:: amti_apache
# Recipe:: default
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


execute "disable default site" do
  command "sudo a2dissite 000-default.conf"
end

directory node["app"]["path"] + "/" + node['app']['project_dir'] do
  owner "www-data"
  group "www-data"
  mode 00755
  action :create
  recursive true
end

directory "/vagrant/" + node['app']['project_dir'] + "/" + node['app']['public_dir'] do
    mode 00755
    owner "www-data"
    group "www-data"
    action :create
    recursive true
end

template "/etc/apache2/sites-available/000-" + node['app']['server_name'] + ".conf" do
  source 'site.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables(
    :docroot        	 =>  node['app']['path'] + "/" + node['app']['project_dir'] + "/" + node['app']['public_dir'],
    :server_port        	 => 80,
    :server_name     => node["app"]["server_name"],
    :server_alias      => node["app"]["server_alias"],
    :directory_options        	 => "Indexes FollowSymLinks",
    :allow_override        	 => "All")
end

execute "enable site" do
  command "sudo a2ensite 000-" + node['app']['server_name'] + ".conf"
end

execute "set server name in apache2 conf-available" do
  command "echo 'ServerName "+node['app']['server_name']+"' >> /etc/apache2/conf-available/server-name.conf"
end


execute "add apache2 server-name.conf" do
  command "sudo a2enconf server-name.conf"
end


execute "restart apache2" do
  command "sudo apache2ctl restart"
end
