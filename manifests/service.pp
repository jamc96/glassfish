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
  $service_ensure = 'running',
  $domain         = 'domain1',
  $port           = '4848',
){
  # create service glassfish
  service { 'glassfish':
    ensure  => $service_ensure,
    name    => "${service_name}_${domain}",
    start   => "/etc/init.d/${service_name}_${domain} start",
    stop    => "/etc/init.d/${service_name}_${domain} stop",
    restart => "/etc/init.d/${service_name}_${domain} restart",
  }
}
