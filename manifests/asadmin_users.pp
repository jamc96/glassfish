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
  Optional[String] $passfile_path            = undef,
  Optional[String] $asadmin_path             = undef,
) {
  # Setting up asadmin binary full path
  Exec{
    path  => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${asadmin_path}",
  }
  # Configure admin and master password
  if $as_admin_password and $as_admin_master_password {
    file { 'passfile':
      ensure  => file,
      owner   => 'glassfish',
      group   => 'glassfish',
      content => template("${module_name}/passfile.erb"),
      path    => $passfile_path,
    }
    exec { 'change_master_password':
      command     => "asadmin change-master-password --passwordfile=${passfile_path} --savemasterpassword",
      refreshonly => true,
      creates     => File['passfile'],
    }

    if $as_admin_user{
      #Service['glassfish'] -> Exec['change_admin_password']
      # exec { 'change_admin_password':
      #  command     => "--user ${as_admin_user} --passwordfile=${passfile_path} change-admin-password",
      #  refreshonly => true,
      #  suscribe    => File['passfile'],
      #}
    }
  }
}
