# glassfish::service
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::service
class glassfish::service(
  $service_name   = 'glassfish',
  $domain         = 'domain1',
  $port           = '4848',
){
  # create service glassfish
  service { 'glassfish':
    ensure  => 'running',
    name    => "${service_name}_${domain}",
    start   => "/etc/init.d/${service_name}_${domain} start",
    stop    => "/etc/init.d/${service_name}_${domain} stop",
    restart => "/etc/init.d/${service_name}_${domain} restart",
  }
}
