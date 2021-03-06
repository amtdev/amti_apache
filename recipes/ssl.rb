#
# Cookbook:: amti_apache
# Recipe:: ssl
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
  command "sudo a2dissite default-ssl.conf"
end

if '/etc/ssl/certs/' !=  node['app']['cert_path']
    directory node["app"]["cert_path"] do
      owner "root"
      group "root"
      mode 0644
      action :create
      recursive true
    end
end

if 'ssl-cert-snakeoil.pem' !=  node['app']['cert_name']
    cookbook_file  node['app']['cert_path'] + node['app']['cert_name'] do
      source node['app']['source_folder'] +"/"+ node['app']['cert_name']
      backup false
      #source node['app']['source_folder'] + "/" + node['app']['cert_name']
      action :create
    end
end

if '/etc/ssl/private/' !=  node['app']['key_path']
    directory node["app"]["key_path"] do
      owner "root"
      group "root"
      mode 0644
      action :create
      recursive true
    end
end

if 'ssl-cert-snakeoil.key' !=  node['app']['key_name']
    cookbook_file  node['app']['key_path'] + node['app']['key_name'] do
      source node['app']['source_folder'] +"/"+ node['app']['key_name']
      owner "root"
      group "ssl-cert"
      mode "0640"
      backup false
      action :create
    end
end

if 'null' !=  node['app']['chain_file_path']
    directory node["app"]["chain_file_path"] do
      owner "root"
      group "root"
      mode 0644
      action :create
      recursive true
    end
end

if 'null' !=  node['app']['chain_file_name']
    cookbook_file  node['app']['chain_file_path'] + node['app']['chain_file_name'] do
      source node['app']['source_folder'] +"/"+ node['app']['chain_file_name']
      backup false
      action :create
    end
end

template "/etc/apache2/sites-available/000-" + node['app']['server_name'] + "-ssl.conf" do
  source 'site.conf.ssl.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables(
    :docroot        	 =>  node['app']['path'] + "/" + node['app']['project_dir'] + "/" + node['app']['public_dir'],
    :server_port        	 => "443",
    :server_name     => node["app"]["server_name"],
    :server_alias      => node["app"]["server_alias"],
    :cert_name  =>  node["app"]["cert_name"],
    :cert_path  =>  node["app"]["cert_path"],
    :key_name  =>  node["app"]["key_name"],
    :key_path  =>  node["app"]["key_path"],
    :chain_file_name  =>  node["app"]["chain_file_name"],
    :chain_file_path  =>  node["app"]["chain_file_path"],
    :directory_options        	 => "Indexes FollowSymLinks",
    :allow_override        	 => "All")
end

execute "enable site" do
  command "sudo a2ensite 000-" + node['app']['server_name'] + "-ssl.conf"
end

execute "enable apache ssl module" do
  command "sudo a2enmod ssl"
end

service "apache2" do
  action :restart
end

#execute "restart apache2" do
#  command "sudo service apache2 restart"
#end