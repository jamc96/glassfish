# glassfish::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::config
class glassfish::config inherits glassfish {

  # archive module
  include ::archive
  # create config files
  file { $glassfish::use_config_path :
    ensure                  => $glassfish::config_ensure,
    owner                   => 'glassfish',
    group                   => 'glassfish',
    selinux_ignore_defaults => true,
    require                 => User['glassfish'],
  }
  # uncompress the glassfish package
  archive { $glassfish::use_package_name:
    ensure       => $glassfish::package_ensure,
    path         => "${glassfish::as_root_path}/${glassfish::use_package_name}",
    source       => $glassfish::use_package_source,
    extract      => true,
    extract_path => "${glassfish::use_config_path}/",
    cleanup      => false,
    user         => 'glassfish',
    group        => 'glassfish',
    require      => File[$glassfish::use_config_path],
  }
  # validate glassfish version 
  if $glassfish::use_config_path =~ '(\d+)[.]' {
    # create symlink to bin folder 
    file { "${glassfish::as_root_path}/bin":
      ensure  => 'link',
      target  => "${glassfish::use_config_path}/glassfish${1}/bin",
      require => Archive[$glassfish::use_package_name],
    }
    # remove empty links on installation
    file { '/usr/bin/asadmin':
      ensure  => 'absent',
      require => File["${glassfish::as_root_path}/bin"],
    }
  }
  # create init service file
  ::glassfish::create_daemon{ 'glassfish':
    asadmin_path => $glassfish::asadmin_path,
    domain       => $glassfish::domain,
    port         => $glassfish::port,
    require      => Archive[$glassfish::use_package_name],
  }
  # master password files
  file {
    "${glassfish::as_root_path}/.as_master_pass":
      ensure  => 'file',
      mode    => '0644',
      notify  => Exec['change_master_password'],
      content => template("${module_name}/as_master_pass.erb"),
      require => Glassfish::Create_daemon['glassfish'];
    "${glassfish::as_root_path}/.as_admin_pass":
      ensure  => 'file',
      mode    => '0644',
      notify  => Exec['change_admin_password'],
      content => template("${module_name}/as_admin_pass.erb"),
      require => Glassfish::Create_daemon['glassfish'];
  }
  # change master password
  exec { 'change_master_password':
    command     => "${glassfish::asadmin_path}/asadmin change-master-password --passwordfile=${glassfish::as_root_path}/.as_master_pass --savemasterpassword",
    refreshonly => true,
    notify      => Exec['start_glassfish_service'],
  }
  # change admin password
  exec { 'change_admin_password':
    command     => "${glassfish::asadmin_path}/asadmin --user ${glassfish::as_admin_user} --passwordfile=${glassfish::as_root_path}/.as_admin_pass change-admin-password",
    refreshonly => true,
    notify      => Exec['enable_secure_admin'],
  }
  # enable secure admin and restart service
  exec { 'enable_secure_admin':
    command     => "${glassfish::asadmin_path}/asadmin enable-secure-admin --passwordfile=${glassfish::as_root_path}/.as_admin_pass",
    refreshonly => true,
    notify      => [Exec['restart_glassfish_service'],Exec['set_admin_listener_port']],
  }
  # set admin listener port 
  $set  = "${glassfish::asadmin_path}/asadmin --user ${glassfish::as_admin_user} --passwordfile=${glassfish::as_root_path}/.as_admin_pass set"
  $adm_list_config = "configs.config.server-config.network-config.network-listeners.network-listener.admin-listener.port=${glassfish::port}"
  exec { 'set_admin_listener_port':
    command     => "${set} ${adm_list_config}",
    refreshonly => true,
    notify      => Exec['set_secure_port'],
  }
  # set http port
  $secure_port_config = "configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.port=${glassfish::secure_port}"
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
    command     => "/etc/init.d/glassfish_${glassfish::domain} start",
    refreshonly => true,
  }
}
