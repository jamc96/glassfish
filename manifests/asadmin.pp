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
#
define glassfish::asadmin(
  String $as_admin_user           = 'admin',
  Pattern[/^[.+_0-9:~-]+$/] $port = '4848',
  Array $set                      = [],
  Array $create_managed           = [],
  String $as_root_path            = '/home/glassfish',
  Optional[String] $as_admin_path = "${as_root_path}/.as_admin_pass",
  Optional[String] $asadmin_path  = undef,
) {
  # global variables
  if !$asadmin_path {
    fail('$asadmin_path is required to create the script file')
  }
  case $facts['os']['name'] {
    'CentOS': {
      $shell_path = $facts['operatingsystemmajrelease'] ? {
        '7' => '/usr/bin/sh',
        default => '/bin/sh',
      }
    }
    default: {
      $shell_path = '/bin/sh'
    }
  }
  # create configs script
  file { "${as_root_path}/configs.sh":
    ensure       => file,
    owner        => 'root',
    group        => 'root',
    mode         => '0500',
    # notify       => Exec["${as_root_path}/configs.sh"],
    validate_cmd => "${shell_path} -n %",
    content      => template("${module_name}/configs.erb");
  }
  # apply configuration
  exec { "${as_root_path}/configs.sh":
    command     => "sh ${as_root_path}/configs.sh",
    refreshonly => true,
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
  }
}
