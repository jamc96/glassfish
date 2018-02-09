# glassfish::asadmin
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   glassfish::asadmin { 'namevar': }
define glassfish::asadmin(
  String $as_admin_user             = $::glassfish::as_admin_user,
  String $as_admin_password         = $::glassfish::as_admin_password,
  String $as_admin_master_password  = $::glassfish::as_admin_master_password,
  Pattern[/^[.+_0-9:~-]+$/] $port   = $::glassfish::port,
  Optional[String] $configs         = undef,
  Optional[String] $passfile_path   = $::glassfish::passfile_path,
  Optional[String] $asadmin_path    = $::glassfish::asadmin_path,
) {
  # Setting up asadmin binary full path
  Exec{
    path  => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${asadmin_path}",
  }

}
