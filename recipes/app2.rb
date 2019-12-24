#
# Cookbook:: amti_apache
# Recipe:: app2
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

directory node["app2"]["path"] + "/" + node['app2']['project_dir'] do
  owner "www-data"
  group "www-data"
  mode 00755
  action :create
  recursive true
end

directory "/vagrant/" + node['app2']['project_dir'] + "/" + node['app2']['public_dir'] do
    mode 00755
    owner "www-data"
    group "www-data"
    action :create
    recursive true
end

# link "/tmp/new" do
#     to "/tmp/old"
#     link_type :symbolic
#     action :create
# end
link node["app2"]["path"] + "/" + node['app2']['project_dir'] + "/" + node['app2']['public_dir'] do
  to "/vagrant/" + node['app2']['project_dir'] + "/" + node['app2']['public_dir']
    link_type :symbolic
    action :create
end

if "null" !=  node['app2']['private_dir']
    directory "/vagrant/" + node['app2']['project_dir'] + "/" + node['app2']['private_dir'] do
      mode 00755
      owner "www-data"
      group "www-data"
      action :create
      recursive true
    end


    link node["app2"]["path"] + "/" + node['app2']['project_dir'] + "/" + node['app2']['private_dir'] do
      to "/vagrant/" + node['app2']['project_dir'] + "/" + node['app2']['private_dir']
        link_type :symbolic
        action :create
    end
end

template "/etc/apache2/sites-available/111-" + node['app2']['server_name'] + ".conf" do
  source 'site.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables(
    :docroot        	 =>  node['app2']['path'] + "/" + node['app2']['project_dir'] + "/" + node['app2']['public_dir'],
    :server_port        	 => "80",
    :server_name     => node["app2"]["server_name"],
    :server_alias      => node["app2"]["server_alias"],
    :directory_options        	 => "Indexes FollowSymLinks",
    :allow_override        	 => "All")
end

execute "enable site" do
  command "sudo a2ensite 111-" + node['app2']['server_name'] + ".conf"
end

service "apache2" do
  action :restart
end