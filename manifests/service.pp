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
  $as_admin_path  = $::glassfish::as_admin_path,
){
  service { 'glassfish':
    ensure => $service_ensure,
    path   => "${as_admin_path}/asadmin",
    start  => 'start-domain',
    stop   => 'stop-domain',
  }
}
