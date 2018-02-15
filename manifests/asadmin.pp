# glassfish::asadmin
#
# allows to apply configuration on glassfish server through set command o full string
#
# @config apply the glassfish configuration
#
# @value required by config variable
#
# @example
#  glassfish::asadmin { 'default':
#    config => 'configs.config.server-config.network-config.network-listeners.network-listener.admin-listener.port',
#    value  => '4848',
#  }
#
# @concat_str apply configuration with full string
#
# @example
#  glassfish::asadmin { 'deafault':
#    concat_str => 'create-managed-thread-factory --description="Micro Description" --threadpriority=1',
#  }
#
# @java_status change the status of the java process
#
define glassfish::asadmin(
  String $as_admin_user             = $::glassfish::as_admin_user,
  Pattern[/^[.+_0-9:~-]+$/] $port   = $::glassfish::port,
  Optional[String] $config          = undef,
  Optional[String] $value           = undef,
  Optional[String] $passfile_path   = $::glassfish::passfile_path,
  Optional[String] $asadmin_path    = $::glassfish::asadmin_path,
  Boolean $java_status              = true,
  Optional[String] $concat_str      = undef
) {
  if $config {
    # Kill Java process to change the default port
    if $config =~ /(admin-listener.port|http-listener-2.port|port)$/{
      $java_status = false
    }
    if !$value{
      fail('$value parameter is required to apply the configuration')
    }else {
      # create execute command 
      $cmd_asadmin = "--user ${as_admin_user} --port ${port} --passwordfile=${passfile_path} set ${config}=${value}"
    }
  }
  if $concat_str {
    $cmd_asadmin = "--user ${as_admin_user} --port ${port} --passwordfile=${passfile_path} ${concat_str}"
  }
  # apply configuration over glassfish
  if $cmd_asadmin {
    if !$java_status {
      notify { 'test command': message => "${cmd_asadmin} -> kill java" }
    }else{
      notify { 'test command': message => $cmd_asadmin }
    }
  }

}
