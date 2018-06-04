# glassfish::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::config
class glassfish::config(
  $package_ensure           = $::glassfish::package_ensure,
  $package_name             = $::glassfish::use_package_name,
  $package_source           = $::glassfish::use_package_source,
  $config_ensure            = $::glassfish::config_ensure,
  $config_path              = $::glassfish::use_config_path,
  $as_root_path             = $::glassfish::use_as_root_path,
  $manage_user              = $::glassfish::manage_user,
  $asadmin_path             = $::glassfish::asadmin_path,
  $domain                   = $::glassfish::domain,
  $as_admin_user            = $::glassfish::as_admin_user,
  $as_admin_password        = $::glassfish::as_admin_password,
  $as_admin_master_password = $::glassfish::as_admin_master_password,
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
  # set password on admin and asadmin user
  # change master password
  exec { 'change_master_password':
    command     => "${asadmin_path}/asadmin change-master-password --passwordfile=${as_root_path}/.as_master_pass --savemasterpassword",
    refreshonly => true,
    notify      => Service['glassfish'],
  }
  # start glassfish service
  Exec['change_master_password'] -> Service['glassfish']
  # change admin password
  exec { 'change_admin_password':
    command     => "${asadmin_path}/asadmin --user ${as_admin_user} --passwordfile=${as_root_path}/.as_admin_pass change-admin-password",
    refreshonly => true,
    notify      => Service['glassfish'],
  }
  # restart glassfish service
  Exec['change_admin_password'] ~> Service['glassfish']
}
