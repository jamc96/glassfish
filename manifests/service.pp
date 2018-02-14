# glassfish::service
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::service
class glassfish::service(
  $service_ensure = $::glassfish::service_ensure,
  $asadmin_path   = $::glassfish::asadmin_path,
  $service_name   = $::glassfish::service_name,
  $domain         = $::glassfish::domain,
){
  ::glassfish::create_service{ 'default':
    asadmin_path => $asadmin_path,
    domain       => $domain,
    notify       => Service['glassfish'],
  }
  service { 'glassfish':
    ensure => $service_ensure,
    name   => "${service_name}_${domain}",
    start  => "/etc/init.d/${service_name}_${domain} start",
    stop   => "/etc/init.d/${service_name}_${domain} stop",
  }
}
