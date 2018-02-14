  # glassfish
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish
class glassfish(
  Pattern[/latest|^[.+_0-9:~-]+$/] $version          = '4.1',
  Pattern[/present|absent/] $package_ensure          = 'present',
  Pattern[/zip|tar.gz/] $package_type                = 'zip',
  Optional[String] $package_name                     = undef,
  Optional[String] $package_source                   = undef,
  Pattern[/present|absent/] $config_ensure           = 'present',
  Optional[String] $config_path                      = undef,
  Optional[String] $as_admin_user                    = 'admin',
  Optional[String] $as_admin_password                = 'admin',
  Optional[String] $as_admin_master_password         = 'changeit',
  Optional[String] $as_master_path                   = '/tmp/.as_master_pass',
  Optional[String] $as_admin_path                    = '/tmp/.as_admin_pass',
  Pattern[/running|stopped|restart/] $service_ensure = 'running',
  Optional[String] $service_name                     = 'glassfish',
  Optional[String] $domain                           = 'domain1',
  Pattern[/^[0-9]+$/] $port                          = '4848',
  ) {
# Global variables
  $use_version = $version ? {
    'latest' => '5.0',
    default  => $version,
  }
  $use_config_ensure = $config_ensure ? {
    'present' => 'directory',
    default   => $config_ensure,
  }
  $use_config_path = $config_path ? {
    undef   => "/opt/glassfish-${use_version}",
    default => $config_path,
  }
  $use_package_name = $package_name ? {
    undef   => "glassfish-${use_version}.${package_type}",
    default => $package_name,
  }
  $use_package_source = $package_source ? {
    undef   => "http://download.oracle.com/glassfish/${use_version}/release/${use_package_name}",
    default => $package_source,
  }
  $config_v = regsubst($use_version,'^(\d+)(\.(\d+)\.(\d+)|\.(\d+))$','\1')
  $asadmin_path = "${use_config_path}/glassfish${config_v}/glassfish/bin"

  # Configure admin and master password
  if $as_admin_password and $as_admin_master_password {
    file { 'as_master_pass':
      ensure  => file,
      content => template("${module_name}/as_master_pass.erb"),
      path    => $as_master_path,
      before  => Service['glassfish'],
      notify  => Exec['change_master_password'],
    }
    exec { 'change_master_password':
      command     => "${asadmin_path}/asadmin change-master-password --passwordfile=${as_master_path} --savemasterpassword",
      refreshonly => true,
    }

    if $as_admin_user{
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
  class { '::glassfish::install': } ~> class { '::glassfish::service': }
}
