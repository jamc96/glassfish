# glassfish::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::config
class glassfish::config(
  $ensure                   = $::glassfish::config_ensure,
  $path                     = $::glassfish::use_config_path,
  $package_ensure           = $::glassfish::package_ensure,
  $package_name             = $::glassfish::use_package_name,
  $package_source           = $::glassfish::use_package_source,
  $as_root_path             = $::glassfish::as_root_path,
  $asadmin_path             = $::glassfish::asadmin_path,
  $domain                   = $::glassfish::domain,
  $as_admin_user            = $::glassfish::as_admin_user,
  $as_admin_password        = $::glassfish::as_admin_password,
  $as_admin_master_password = $::glassfish::as_admin_master_password,
  $service_name             = $::glassfish::service_name,
  $port                     = $::glassfish::port,
  $secure_port              = $::glassfish::secure_port,
  $owner                    = $::glassfish::owner,
  $group                    = $::glassfish::group,
) {
  #default  values  
  File {
    owner => $owner,
    group => $group,
  }
  # archive module
  include ::archive
  # create config files
  file { $path :
    ensure  => $ensure,
    path    => $path,
    require => User['glassfish'],
  }
  # uncompress the glassfish package
  archive { $package_name:
    ensure       => $package_ensure,
    path         => "${as_root_path}/${package_name}",
    source       => $package_source,
    extract      => true,
    extract_path => "${path}/",
    cleanup      => false,
    user         => $owner,
    group        => $group,
    require      => File[$path],
  }
  if $path =~ '(\d+)[.]' {
    # create symlink to bin folder 
    file { "${as_root_path}/bin":
      ensure  => 'link',
      target  => "${path}/glassfish${1}/bin",
      require => Archive[$package_name],
    }
  }
  # create init service file
  ::glassfish::create_daemon{ 'glassfish':
    asadmin_path => $asadmin_path,
    domain       => $domain,
    port         => $port,
    require      => Archive[$package_name],
  }
  # master password files
  file {
    "${as_root_path}/.as_master_pass":
      ensure  => 'file',
      mode    => '0644',
      notify  => Exec['change_master_password'],
      content => template("${module_name}/as_master_pass.erb"),
      require => Glassfish::Create_daemon['glassfish'];
    "${as_root_path}/.as_admin_pass":
      ensure  => 'file',
      mode    => '0644',
      notify  => Exec['change_admin_password'],
      content => template("${module_name}/as_admin_pass.erb"),
      require => Glassfish::Create_daemon['glassfish'];
  }
  # change master password
  exec { 'change_master_password':
    command     => "${asadmin_path}/asadmin change-master-password --passwordfile=${as_root_path}/.as_master_pass --savemasterpassword",
    refreshonly => true,
    notify      => Exec['start_glassfish_service'],
  }
  # change admin password
  exec { 'change_admin_password':
    command     => "${asadmin_path}/asadmin --user ${as_admin_user} --passwordfile=${as_root_path}/.as_admin_pass change-admin-password",
    refreshonly => true,
    notify      => Exec['enable_secure_admin'],
  }
  # enable secure admin and restart service
  exec { 'enable_secure_admin':
    command     => "${asadmin_path}/asadmin enable-secure-admin --passwordfile=${as_root_path}/.as_admin_pass",
    refreshonly => true,
    notify      => [Exec['restart_glassfish_service'],Exec['set_admin_listener_port']],
  }
  # set admin listener port 
  $set  = "${asadmin_path}/asadmin --user ${as_admin_user} --passwordfile=${as_root_path}/.as_admin_pass set"
  $admin_listener_config = "configs.config.server-config.network-config.network-listeners.network-listener.admin-listener.port=${port}"
  exec { 'set_admin_listener_port':
    command     => "${set} ${admin_listener_config}",
    refreshonly => true,
    notify      => Exec['set_secure_port'],
  }
  # set http port
  $secure_port_config = "configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.port=${secure_port}"
  exec { 'set_secure_port':
    command     => "${set} ${secure_port_config}",
    refreshonly => true,
    notify      => Exec['stop_java'],
  }
  # stop all java process and start service
  exec { 'stop_java':
    command     => 'kill -9 `pidof java`',
    path        => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
    refreshonly => true,
    notify      => Exec['refresh_glassfish_service'],
  }
  # fake refresh of service
  exec { 'refresh_glassfish_service':
    command     => "/etc/init.d/${service_name}_${domain} start",
    refreshonly => true,
  }
}
