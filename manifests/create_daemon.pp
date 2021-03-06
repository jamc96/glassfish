# glassfish::create_daemon
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   glassfish::create_daemon { 'namevar': }
define glassfish::create_daemon(
  $service_name                  = 'glassfish',
  $domain                        = 'domain1',
  $port                          = '4848',
  Optional[String] $asadmin_path = undef,
) {
  if !$asadmin_path {
    # requiring $asadmin_path variable
    fail('$asadmin_path is required to create the service file')
  } else {
    # creating init file 
    file { "/etc/init.d/${service_name}_${domain}":
      ensure  => 'present',
      mode    => '0775',
      content => template("${module_name}/rhel_service.erb"),
    }
  }
}
