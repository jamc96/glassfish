# test case 2
#
# This case will test the glassfish class when an external java class is managing the java resources, 
# also the user and group of glassfish will be managed externally.
# Different version of glassfish will be used and the port and secure port will be changed as well. 
# The defined type asadmin will be called from the init file, and the parameters required will be provided 
# as expected. 
# 
# java class 
java::oracle { 'jdk8' :
  ensure  => 'present',
  version => '8',
  java_se => 'jdk',
}
# createing user and group glassfish
group { 'glassfish':
  gid => '2100',
}
user { 'glassfish':
  ensure  => present,
  comment => 'Managed by Puppet',
  home    => '/home/glassfish',
  uid     => '2100',
  gid     => '2100',
  require => Group['glassfish'],
}
# configuration values 
$configs = [
  'server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled=true',
  'server.admin-service.das-config.autodeploy-enabled=false',
  'server.admin-service.das-config.autodeploy-enabled=true',
  'server.network-config.transports.transport.tcp.acceptor-threads=1',
  'server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=20',
  'server.network-config.protocols.protocol.http-listener-2.http.max-post-size-bytes=10',
]
# class glassfish
class { '::glassfish':
  version                  => '5.0',
  manage_user              => false,
  as_admin_master_password => 'Test01$1234',
  as_admin_password        => 'Test01$1234',
  port                     => '40575',
  secure_port              => '8443',
  asadmin_set              => $configs,
}
# adding relationship between user and class
Java::Oracle['jdk8'] -> User['glassfish'] -> Class['glassfish']
