# glassfish::create_service
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   glassfish::create_service { 'namevar': }
define glassfish::create_service(
  $service_name                  = $::glassfish::service_name,
  $domain                        = $::glassfish::domain,
  $port                          = $::glassfish::port,
  Optional[String] $asadmin_path = $::glassfish::asadmin_path,
) {
  if !$asadmin_path {
    # requiring $asadmin_path variable
    fail('$asadmin_path is required to create the service file')
  } else {
    # creating init file 
    file { 'create_service':
      ensure  => 'present',
      path    => "/etc/init.d/${service_name}_${domain}",
      mode    => '0775',
      content => template("${module_name}/rhel_service.erb"),
    }
  }
}
