#
# Cookbook Name:: kkafka
# Recipe:: _configure
#

directory node['kkafka']['config_dir'] do
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '750'
  recursive true
end

template ::File.join(node['kkafka']['config_dir'], 'log4j.properties') do
  source 'log4j.properties.erb'
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '640'
  helpers(Kafka::Log4J)
  variables({
    config: node['kkafka']['log4j'],
  })
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

template ::File.join(node['kkafka']['config_dir'], 'server.properties') do
  source 'server.properties.erb'
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '640'
  helper :config do
    node['kkafka']['broker'].sort_by(&:first)
  end
  helpers(Kafka::Configuration)
  # variables({
  #   zk_ip: zk_ip
  # })
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end


template kafka_init_opts['env_path'] do
  source kafka_init_opts.fetch(:env_template, 'env.erb')
  owner 'root'
  group 'root'
  mode '640'
  variables({
    main_class: 'kafka.Kafka',
  })
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end

file "#{node['kkafka']['config_dir']}/jmxremote.password" do 
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '600'
  content "#{node['kkafka']['jmx_user']} #{node['kkafka']['jmx_password']}"  
end

file "#{node['kkafka']['config_dir']}/jmxremote.access" do 
  owner node['kkafka']['user']
  group node['kkafka']['group']
  mode '600'
  content "#{node['kkafka']['jmx_user']} readwrite" 
end

cookbook_file "#{node['kkafka']['config_dir']}/kafka.yaml" do
  owner node['kkafka']['user']
  group node['kkafka']['group']
  source 'kafka.yaml'
  mode '0750'
  action :create
end

deps = ""
if exists_local("kzookeeper", "default")
  deps = "zookeeper.service"
end
if exists_local("ndb", "mysqld")
  deps += " mysqld.service"
end

template kafka_init_opts['script_path'] do
  source kafka_init_opts['source']
  owner 'root'
  group 'root'
  mode kafka_init_opts['permissions']
  variables({
    deps: deps,              
    daemon_name: 'kafka',
    port: node['kkafka']['broker']['port'],
    user: node['kkafka']['user'],
    env_path: kafka_init_opts['env_path'],
    ulimit: node['kkafka']['ulimit_file'],
    kill_timeout: node['kkafka']['kill_timeout'],
  })
  helper :controlled_shutdown_enabled? do
    !!fetch_broker_attribute(:controlled, :shutdown, :enable)
  end
  if restart_on_configuration_change?
    notifies :create, 'ruby_block[coordinate-kafka-start]', :immediately
  end
end


remote_file "#{node['kkafka']['install_dir']}/libs/hops-kafka-authorizer-#{node['kkafka']['authorizer_version']}.jar" do
  source node['kkafka']['authorizer_download_url']
  user 'root'
  group 'root'
  mode 0755
  action :create_if_missing
end


include_recipe node['kkafka']['start_coordination']['recipe']
