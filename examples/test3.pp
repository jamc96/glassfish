# test case 3
# 
# This case will test the defined type asadmin in order to create a shell script,
# add owner, group and permissions. It also will check the sytax of the shell file and execute it. 
#
#
$configs = [
  'server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled=true',
  'server.admin-service.das-config.autodeploy-enabled=false',
  'server.admin-service.das-config.autodeploy-enabled=true',
  'server.network-config.transports.transport.tcp.acceptor-threads=1',
  'server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=20',
  'server.network-config.protocols.protocol.http-listener-2.http.max-post-size-bytes=10',
]
$create_managed = [
'thread-factory --description="Microarchitecture High Priority Managed Thread Factory" --threadpriority=6 concurrent/__Microarch/HighPriority',
'thread-factory --description="Microarchitecture Low Priority Managed Thread Factory" --threadpriority=4 concurrent/__Microarch/LowPriority',
]

glassfish::asadmin { 'tunning':
  set            => $configs,
  asadmin_path   => '/opt/glassfish-4.1/glassfish4/bin/asadmin',
  create_managed => $create_managed,
}
