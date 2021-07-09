include_attribute "ndb"
include_attribute "kagent"

#
# Cookbook Name:: kkafka
# Attributes:: default
#

#
# Version of Kafka to install.
default['kkafka']['version'] = '2.3.0'
# Version used for properties file
default['kkafka']['version_properties'] = '1.0'
# HopsKafkaAuthorizer version
default['kkafka']['authorizer_version'] = '2.3.0-SNAPSHOT'

#
# Scala version of Kafka.
default['kkafka']['scala_version'] = '2.11'

#
# Base URL for Kafka releases. The recipes will a download URL using the
# `base_url`, `version` and `scala_version` attributes.
#default['kkafka']['base_url'] = 'https://archive.apache.org/dist/kafka'
#'http://snurran.sics.se/hops'
default['kkafka']['base_url'] = node['download_url']
default['kkafka']['download_url'] = kafka_download_uri(kafka_tar_gz)
default['kkafka']['authorizer_download_url'] =  "#{node['download_url']}/hops-kafka-authorizer/#{node['kkafka']['authorizer_version']}/hops-kafka-authorizer-#{node['kkafka']['authorizer_version']}.jar"

#
# SHA-256 checksum of the archive to download, used by Chef's `remote_file`
# resource.
default['kkafka']['checksum'] = '80bae8179ffa3e1fb32a98d669b552d52d1d69f7d3437c7ffead7c6d6413b74c'


#
# MD5 checksum of the archive to download, which will be used to validate that
# the "correct" archive has been downloaded.
default['kkafka']['md5_checksum'] = ''


#
# Directory where to install Kafka.
default['kkafka']['dir'] = node['install']['dir'].empty? ? "/opt" : node['install']['dir']

default['kkafka']['install_dir'] = "#{node['kkafka']['dir']}/kafka"

# Data volume directories
default['kkafka']['data_volume']['root_dir']     = "#{node['data']['dir']}/kafka"
default['kkafka']['data_volume']['app_log_dir']  = "#{node['kkafka']['data_volume']['root_dir']}/logs"
default['kkafka']['data_volume']['logs_dir']     = "#{node['kkafka']['data_volume']['root_dir']}/kafka-logs"

#
# Directory where to install *this* version of Kafka.
# For actual default value see `_defaults` recipe.
default['kkafka']['version_install_dir'] = %(#{node['kkafka']['install_dir']}-#{node['kkafka']['version']})

#
# Directory where the downloaded archive will be extracted to.
default['kkafka']['build_dir'] = ::File.join(Dir.tmpdir, 'kafka-build')

#
# Directory where to store logs from Kafka.
default['kkafka']['log_dir'] = "#{node['kkafka']['install_dir']}/logs"

#
# Directory where to store kafka libs 
default['kkafka']['libs_dir'] = "#{node['kkafka']['install_dir']}/libs" 

#
# Directory where to keep Kafka configuration files. For the
# actual default value see `_defaults` recipe.
default['kkafka']['config_dir'] = "#{node['kkafka']['install_dir']}/config"

# JXM prometheus monitoring 
default['kkafka']['jmx']['prometheus_exporter']['version']    = "0.12.0"
default['kkafka']['jmx']['prometheus_exporter']['url']        = "#{node['download_url']}/prometheus/jmx_prometheus_javaagent-#{node['kkafka']['jmx']['prometheus_exporter']['version']}.jar"
default['kkafka']['metrics_port']                             = "19901"

#
# JMX port for Kafka.
default['kkafka']['jmx_port']                 = 19999
default['kkafka']['jmx_user']                 = "kafkaAdmin"
default['kkafka']['jmx_password']             = "kafkaAdmin"

#
# JMX configuration options for Kafka.
default['kkafka']['jmx_opts'] = [
  "-javaagent:#{node['kkafka']['libs_dir']}/jmx_prometheus_javaagent-#{node['kkafka']['jmx']['prometheus_exporter']['version']}.jar=#{node['kkafka']['metrics_port']}:#{node['kkafka']['config_dir']}/kafka.yaml",
  "-Dcom.sun.management.jmxremote",
  "-Dcom.sun.management.jmxremote.authenticate=true",
  "-Dcom.sun.management.jmxremote.password.file=#{node['kkafka']['config_dir']}/jmxremote.password",
  "-Dcom.sun.management.jmxremote.access.file=#{node['kkafka']['config_dir']}/jmxremote.access",
  "-Dcom.sun.management.jmxremote.ssl=false",
  "-Djava.net.preferIPv4Stack=true"
].join(' ')

#
# User for directories, configuration files and running Kafka.
default['kkafka']['user'] = node['install']['user'].empty? ? 'kafka' : node['install']['user']
default['kkafka']['user-home'] = "/home/#{node['kkafka']['user']}"

#
# Group for directories, configuration files and running Kafka.
default['kkafka']['group'] = node['install']['user'].empty? ? 'kafka' : node['install']['user']

#
# Should node['kkafka']['user'] and node['kkafka']['group'] be created?
default['kkafka']['manage_user'] = true

#
# JVM heap options for Kafka.
default['kkafka']['heap_opts'] = '-Xmx4G -Xms1G'

#
# Generic JVM options for Kafka.
default['kkafka']['generic_opts'] = nil

#
# GC log options for Kafka. For the actual default value
# see `_defaults` recipe.
default['kkafka']['gc_log_opts'] = nil

#
# JVM Performance options for Kafka.
default['kkafka']['jvm_performance_opts'] = %w[
  -server
  -XX:+UseCompressedOops
  -XX:+UseParNewGC
  -XX:+UseConcMarkSweepGC
  -XX:+CMSClassUnloadingEnabled
  -XX:+CMSScavengeBeforeRemark
  -XX:+DisableExplicitGC
  -Djava.awt.headless=true
].join(' ')

#
# The type of "init" system to install scripts for. Valid values are currently
# :sysv, :systemd and :upstart.
default['kkafka']['init_style'] = :systemd

#
# The ulimit file limit.
# If this value is not set, Kafka will use whatever the system default is.
# Depending on your system setup you might want to set this to a rather high
# value, or you will most likely run into issues with Kafka simply dying for no
# particular reason as it needs to keep a lot of file handles for socket
# connections and log files for all partitions.
default['kkafka']['ulimit_file'] = 65535

#
# Automatically start kkafka service.
default['kkafka']['automatic_start'] = true

#
# Automatically restart kkafka on configuration change.
# This also implies `automatic_start` even if it's set to `false`.
# The reason for this is that I can see the need for automatically starting
# Kafka if it's not running, but not necessarily restart on configuration
# changes.
default['kkafka']['automatic_restart'] = true

#
# Attribute to set the recipe to used to coordinate Kafka service start
# if nothing is set the default recipe "_coordiante" will be used
# Refer to issue #58 for details.
default['kkafka']['start_coordination']['recipe'] = 'kkafka::_coordinate'

#
# Attribute to set the timeout in seconds when stopping the broker
# before sending SIGKILL (or equivalent).
default['kkafka']['kill_timeout'] = 10

#
# `broker` namespace for configuration of a broker.
# Initially set to an empty Hash to avoid having `fetch(:broker, {})`
# statements in helper methods and the alike.
default['kkafka']['broker'] = {}

#Kafka rack id
default['kkafka']['broker']['rack']['id'] = 'hdp1'

#
# Root logger level and appender.
default['kkafka']['log4j']['root_logger'] = 'INFO, kafkaAppender'

#
# Appender definitions for various Kafka classes.
default['kkafka']['log4j']['appenders'] = {
  'kafkaAppender' => {
    type: 'org.apache.log4j.RollingFileAppender',
    file: lazy { %(#{node['kkafka']['log_dir']}/kafka.log) },
    Max_File_Size: '256MB',
    Max_Backup_Index: '20',
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'stateChangeAppender' => {
    type: 'org.apache.log4j.RollingFileAppender',
    file: lazy { %(#{node['kkafka']['log_dir']}/kafka-state-change.log) },
    Max_File_Size: '128MB',
     Max_Backup_Index: '2',
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'requestAppender' => {
    type: 'org.apache.log4j.RollingFileAppender',
    file: lazy { %(#{node['kkafka']['log_dir']}/kafka-request.log) },
    Max_File_Size: '128MB',
     Max_Backup_Index: '2',
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'controllerAppender' => {
    type: 'org.apache.log4j.RollingFileAppender',
    file: lazy { %(#{node['kkafka']['log_dir']}/kafka-controller.log) },
    Max_File_Size: '128MB',
     Max_Backup_Index: '2',
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'authorizerAppender' => {
    type: 'org.apache.log4j.RollingFileAppender',
    file: lazy { %(#{node['kkafka']['log_dir']}/kafka-authorizer.log) },
    Max_File_Size: '128MB',
     Max_Backup_Index: '2',
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
}

#
# Logger definitions.
default['kkafka']['log4j']['loggers'] = {
  'org.IOItec.zkclient.ZkClient' => {
    level: 'INFO',
  },
  'kafka.network.RequestChannel$' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.request.logger' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.controller' => {
    level: 'INFO',
    appender: 'controllerAppender',
    additivity: false,
  },
  'state.change.logger' => {
    level: 'INFO',
    appender: 'stateChangeAppender',
    additivity: false,
  },
  'kafka.authorizer.logger' => {
    level: 'WARN',
    appender: 'authorizerAppender',
    additivity: false,
  },
}

default['kkafka']['broker']['host']['name']                                           = ""
default['kkafka']['broker']['broker']['id']                                           = -1
default['kkafka']['broker']['advertised']['listeners']                                = ""
default['kkafka']['broker']['port']                                                   = 9091
default['kkafka']['broker']['inter']['broker']['listener']['name']                    = "INTERNAL"
default['kkafka']['broker']['log']['retention']['hours']                              = 240
default['kkafka']['broker']['num']['network']['threads']                              = 3
default['kkafka']['broker']['num']['io']['threads']                                   = 8
default['kkafka']['broker']['num']['recovery']['threads']['per']['data']['dir']       = 1
default['kkafka']['broker']['num']['replica']['fetchers']                             = 1
default['kkafka']['broker']['queued']['max']['requests']                              = 500
default['kkafka']['broker']['socket']['send']['buffer']['bytes']                      = 100 * 1024
default['kkafka']['broker']['socket']['receive']['buffer']['bytes']                   = 100 * 1024
default['kkafka']['broker']['socket']['request']['max']['bytes']                      = 100 * 100 * 1024
default['kkafka']['broker']['num']['partitions']                                      = 1
default['kkafka']['broker']['log']['segment']['bytes']                                = 1024 * 1024 * 1024
default['kkafka']['broker']['log']['roll']['hours']                                   = 24 * 7
default['kkafka']['broker']['log']['retention']['hours']                              = 24 * 7
default['kkafka']['broker']['log']['retention']['bytes']                              = "-1"
default['kkafka']['broker']['log']['retention']['check']['interval']['ms']            = 300000
default['kkafka']['broker']['log']['index']['size']['max']['bytes']                   = "10000000"
default['kkafka']['broker']['log']['index']['interval']['bytes']                      = "4096"
default['kkafka']['broker']['log']['flush']['interval']['messages']                   = "9223372036854775807"
default['kkafka']['broker']['log']['flush']['scheduler']['interval']['ms']            = 3000
default['kkafka']['broker']['log']['flush']['interval']['ms']
default['kkafka']['broker']['log']['message']['timestamp']['difference']['max']['ms'] = 604800000
default['kkafka']['broker']['log']['message']['format']['version']                    = "#{node['kkafka']['version_properties']}"
default['kkafka']['broker']['leader']['imbalance']['check']['interval']['seconds']    = 300
default['kkafka']['broker']['leader']['imbalance']['per']['broker']['percentage']     = 10
default['kkafka']['broker']['log']['dir']                                             = "#{node['kkafka']['dir']}/kafka-logs"
default['kkafka']['broker']['log']['dirs']                                            = "#{node['kkafka']['dir']}/kafka-logs"
default['kkafka']['broker']['log']['flush']['offset']['checkpoint']['interval']['ms'] = 60000
default['kkafka']['broker']['offsets']['topic']['replication']['factor']              = 1
default['kkafka']['broker']['queued']['max']['requests']                              = 500
default['kkafka']['broker']['quota']['consumer']['default']                           = 9223372036854775807
default['kkafka']['broker']['quota']['producer']['default']                           = 9223372036854775807
default['kkafka']['broker']['replica']['fetch']['max']['bytes']                       = 1048576
default['kkafka']['broker']['replica']['fetch']['min']['bytes']                       = 1
default['kkafka']['broker']['replica']['fetch']['wait']['max']['ms']                  = 500
default['kkafka']['broker']['replica']['high']['watermark']['checkpoint']['interval']['ms']    = 5000
default['kkafka']['broker']['replica']['lag']['time']['max']['ms']                    = 10000
default['kkafka']['broker']['replica']['socket']['receive']['buffer']['bytes']        = 65536
default['kkafka']['broker']['replica']['socket']['timeout']['ms']                     = 30000
default['kkafka']['broker']['request']['timeout']['ms']                               = 30000
default['kkafka']['broker']['message']['max']['bytes']                                = "1000012"
default['kkafka']['broker']['default']['replication']['factor']                       = 1
default['kkafka']['broker']['log']['cleaner']['enable']                               = "true"
default['kkafka']['broker']['log']['cleaner']['io']['buffer']['load']['factor']       = "0.9"


# values are: PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL
#default['kkafka']['broker']['security']['inter']['broker']['protocol']               = "SSL"
default['kkafka']['broker']['inter']['broker']['protocol']['version']                 = node['kkafka']['version_properties']
default['kkafka']['broker']['broker']['rack']                                         = node['kkafka']['broker']['rack']['id']
default['kkafka']['broker']['listener']['security']['protocol']['map']                = "INTERNAL:SSL,EXTERNAL:SSL"

default['kkafka']['broker']['authorizer']['class']['name']                            = "io.hops.kafka.HopsAclAuthorizer"
default['kkafka']['broker']['ssl']['endpoint']['identification']['algorithm']         = ""
default['kkafka']['broker']['principal']['builder']['class']                          = "io.hops.kafka.HopsPrincipalBuilder"
default['kkafka']['broker']['allow']['everyone']['if']['no']['acl']['found']          = "false"
default['kkafka']['broker']['delete']['topic']['enable']                              = "true"

default['kkafka']['broker']['zookeeper']['connection']['timeout']['ms']               = 30000
default['kkafka']['broker']['zookeeper']['sync']['time']['ms']                        = 2000
default['kkafka']['broker']['zookeeper']['session']['timeout']['ms']                  = 30000
default['kkafka']['broker']['zookeeper']['set']['acl']                                = "false"

#HopsAclAuthorizer database pool properties
default['kkafka']['broker']['database']['pool']['prepstmt']['cache']['enabled']       = "true"
default['kkafka']['broker']['database']['pool']['prepstmt']['cache']['size']          = "150"
default['kkafka']['broker']['database']['pool']['prepstmt']['cache']['sql']['limit']  = "2048"
default['kkafka']['broker']['database']['pool']['size']                               = "10"
default['kkafka']['broker']['acl']['polling']['frequency']['ms']                      = "1000"

# Usernames and passwords of non-superusers in MySQL
default['kkafka']['mysql']['user']                                                    = "kafka"
default['kkafka']['mysql']['password']                                                = "kafka"

if node['vagrant'] == "false"
  default['kkafka']['broker']['super']['users']                                       = "User:#{node['fqdn']};User:#{node['kkafka']['user']}"
else
  default['kkafka']['broker']['super']['users']                                       = "User:hopsworks0;User:#{node['kkafka']['user']}"
end


default['kkafka']['offset_monitor']['version']                                        = "0.2.1"
default['kkafka']['offset_monitor']['url']                                            = "#{node['download_url']}/KafkaOffsetMonitor-assembly-" + node['kkafka']['offset_monitor']['version'] + ".jar"
default['kkafka']['offset_monitor']['port']                                           = "11111"


default['kkafka']['systemd']                                                          = "true"
