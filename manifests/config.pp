# glassfish::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::config
class glassfish::config(
  $package_ensure   = $::glassfish::use_package_ensure,
  $package_name     = $::glassfish::use_package_name,
  $package_source   = $::glassfish::use_package_source,
  $config_ensure    = $::glassfish::use_config_ensure,
  $config_path      = $::glassfish::use_config_path,
  $as_root_path     = $::glassfish::use_as_root_path,
  $manage_user      = $::glassfish::manage_user,
  $asadmin_path     = $::glassfish::asadmin_path,
  $domain           = $::glassfish::domain,
  $as_admin_user    = $::glassfish::as_admin_user,
) {
  # archive module
  include ::archive
  # manage glassfish user
  if $manage_user {
    group { 'glassfish':
      gid => '20',
    }
    user { 'glassfish':
      ensure  => present,
      comment => 'Managed by Puppet',
      home    => '/home/glassfish',
      uid     => '501',
      gid     => '20',
      require => Group['glassfish'],
    }
  }
  # downloand and create config files
  file { $config_path :
    ensure  => $config_ensure,
    path    => $config_path,
    require => User['glassfish'],
  }
  archive { $package_name:
    ensure       => $package_ensure,
    path         => "${as_root_path}/${package_name}",
    source       => $package_source,
    extract      => true,
    extract_path => "${config_path}/",
    cleanup      => false,
    require      => File[$config_path],
  }
  # create init service file
  ::glassfish::create_daemon{ 'glassfish':
    asadmin_path => $asadmin_path,
    domain       => $domain,
  }
  # master password files
  file {
    "${as_root_path}/.as_master_pass":
      ensure  => $config_ensure,
      mode    => '0644',
      notify  => Exec['change_master_password'],
      require => Glassfish::Create_daemon['glassfish'];
    "${as_root_path}/.as_admin_pass":
      ensure  => $config_ensure,
      mode    => '0644',
      notify  => Exec['change_admin_password'],
      require => Glassfish::Create_daemon['glassfish'];
  }
  # set password on admin and asadmin user
  exec { 'change_master_password':
    command     => "${asadmin_path}/asadmin change-master-password --passwordfile=${as_root_path}/.as_master_pass --savemasterpassword",
    refreshonly => true,
    notify      => Service['glassfish'],
  }
  exec { 'change_admin_password':
    command     => "${asadmin_path}/asadmin --user ${as_admin_user} --passwordfile=${as_root_path}/.as_admin_pass change-admin-password",
    refreshonly => true,
    notify      => Service['glassfish'],
  }
}