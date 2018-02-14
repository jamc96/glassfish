# glassfish::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::config
class glassfish::config {
  # Create admin and master users by default
  ::glassfish::asadmin_users { 'default':
    as_admin_user            => $glassfish::as_admin_user,
    as_admin_password        => $glassfish::as_admin_password,
    as_admin_master_password => $glassfish::as_admin_master_password,
    as_master_path           => $glassfish::as_master_path,
    as_admin_path            => $glassfish::as_admin_path,
    asadmin_path             => $glassfish::asadmin_path,
  }
}
