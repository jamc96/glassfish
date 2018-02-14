# glassfish::create_users
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   glassfish::asadmin_users { 'namevar': }
define glassfish::asadmin_users(
  Optional[String] $as_admin_user            = undef,
  Optional[String] $as_admin_password        = undef,
  Optional[String] $as_admin_master_password = undef,
  Optional[String] $as_admin_path            = undef,
  Optional[String] $as_master_path           = undef,
  Optional[String] $asadmin_path             = undef,
) {
  # Setting up asadmin binary full path
  Exec{
    path  => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:',
  }
  # Configure admin and master password
  if $as_admin_password and $as_admin_master_password {
    transition { 'stop glassfish service before as_master_pass':
      resource   => Service['glassfish'],
      attributes => { ensure => stopped },
      prior_to   => File['as_master_pass'],
    }
    file { 'as_master_pass':
      ensure  => file,
      content => template("${module_name}/as_master_pass.erb"),
      path    => $as_master_path,
      notify  => Exec['change_master_password'],
      before  => Service['Glassfish'],
    }
    exec { 'change_master_password':
      command     => "${asadmin_path}/asadmin change-master-password --passwordfile=${as_master_path} --savemasterpassword",
      refreshonly => true,
    }

    if $as_admin_user{
      transition { 'start glassfish service before as_admin_pass':
        resource   => Service['glassfish'],
        attributes => { ensure => running },
        prior_to   => File['as_admin_pass'],
      }
      file { 'as_admin_pass':
        ensure  => file,
        content => template("${module_name}/as_admin_pass.erb"),
        path    => $as_admin_path,
        notify  => Exec['change_admin_password'],
        require => Service['glassfish'],
      }
      exec { 'change_admin_password':
        command     => "${asadmin_path}/asadmin --user ${as_admin_user} --passwordfile=${as_admin_path} change-admin-password",
        refreshonly => true,
      }
    }
  }
}


