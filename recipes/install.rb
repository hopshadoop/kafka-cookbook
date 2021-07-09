group node['kkafka']['group'] do
  action :create
  not_if "getent group #{node['kkafka']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['kkafka']['user'] do
  action :create
  gid node['kkafka']['group']
  home node['kkafka']['user-home']
  shell "/bin/bash"
  manage_home true
  system true
  not_if "getent passwd #{node['kkafka']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node["kagent"]["certs_group"] do
  action :manage
  append true
  excluded_members node['kkafka']['user']
  not_if { node['install']['external_users'].casecmp("true") == 0 }
  only_if { conda_helpers.is_upgrade }
end

[
  node['kkafka']['version_install_dir'],
  node['kkafka']['build_dir'],
].each do |dir|
  directory dir do
    owner node['kkafka']['user']
    group node['kkafka']['group']
    mode '755'
    recursive true
  end
end

kkafka_download kafka_local_download_path do
  source node['kkafka']['download_url']
  checksum node['kkafka']['checksum']
  md5_checksum node['kkafka']['md5_checksum']
  not_if { kafka_installed? }
end

execute 'extract-kafka' do
  cwd node['kkafka']['build_dir']
  command <<-EOH.gsub(/^\s+/, '')
    tar zxf #{kafka_local_download_path} && \
    chown -R #{node['kkafka']['user']}:#{node['kkafka']['group']} #{node['kkafka']['build_dir']}
  EOH
  not_if { kafka_installed? }
end

kkafka_install node['kkafka']['version_install_dir'] do
  from kafka_target_path
  not_if { kafka_installed? }
end

# Download JMX exporter
jmx_prometheus_filename = File.basename(node['kkafka']['jmx']['prometheus_exporter']['url'])
remote_file "#{node['kkafka']['libs_dir']}/#{jmx_prometheus_filename}" do
  source node['kkafka']['jmx']['prometheus_exporter']['url']
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '0755'
  action :create
end

directory node['data']['dir'] do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
  not_if { ::File.directory?(node['data']['dir']) }
end

directory node['kkafka']['data_volume']['logs_dir'] do
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '770'
  action :create
  recursive true
  not_if { File.directory?(node['kkafka']['data_volume']['logs_dir']) }
end

kafka_log_dirs.each do |dir|
  bash "Move Kafka logs #{dir} to data volume" do
    user 'root'
    code <<-EOH
      set -e
      mv -f #{dir}/* #{node['kkafka']['data_volume']['logs_dir']}
      rm -rf #{dir}
    EOH
    only_if { conda_helpers.is_upgrade }
    only_if { File.directory?(dir)}
    not_if { File.symlink?(dir)}
  end

  link dir do
    owner node['kkafka']['user']
    group node['kkafka']['group']
    mode '770'
    to node['kkafka']['data_volume']['logs_dir']
  end
end

directory node['kkafka']['data_volume']['app_log_dir'] do
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '0750'
end

bash 'Move Kafka application logs to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['kkafka']['log_dir']}/* #{node['kkafka']['data_volume']['app_log_dir']}
    rm -rf #{node['kkafka']['log_dir']}
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['kkafka']['log_dir'])}
  not_if { File.symlink?(node['kkafka']['log_dir'])}
end

link node['kkafka']['log_dir'] do
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '0750'
  to node['kkafka']['data_volume']['app_log_dir']
end
