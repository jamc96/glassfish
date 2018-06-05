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
  Enum['present','absent'] $package_ensure           = 'present',
  Enum['zip','tar'] $package_type                    = 'zip',
  Optional[String] $package_name                     = undef,
  Optional[String] $package_source                   = undef,
  Enum['directory','absent'] $config_ensure          = 'directory',
  Optional[String] $config_path                      = undef,
  String $as_admin_user                              = 'admin',
  String $as_admin_password                          = 'admin',
  String $as_admin_master_password                   = 'changeit',
  Optional[String] $as_root_path                     = undef,
  Enum['running','stopped'] $service_ensure          = 'running',
  Optional[String] $service_name                     = 'glassfish',
  Optional[String] $domain                           = 'domain1',
  Pattern[/^[0-9]+$/] $port                          = '4848',
  Pattern[/^[0-9]+$/] $https_port                    = '8181',
  Pattern[/^[0-9]+$/] $http_port                     = '82020',
  Boolean $manage_user                               = true,
  Boolean $manage_java                               = true,
  ) {
# Global variables
  $use_version = $version ? {
    'latest' => '5.0',
    default  => $version,
  }
  $use_config_path = $config_path ? {
    undef   => "/opt/glassfish-${use_version}",
    default => $config_path,
  }
  $use_package_type = $package_type ? {
    'tar' => 'tar.gz',
    default => $package_type,
  }
  $use_package_name = $package_name ? {
    undef   => "glassfish-${use_version}.${use_package_type}",
    default => $package_name,
  }
  $use_package_source = $package_source ? {
    undef   => "http://download.oracle.com/glassfish/${use_version}/release/${use_package_name}",
    default => $package_source,
  }
  $use_as_root_path = $as_root_path ? {
    undef   => '/home/glassfish',
    default => $as_root_path,
  }
  $config_v = regsubst($use_version,'^(\d+)(\.(\d+)\.(\d+)|\.(\d+))$','\1')
  $asadmin_path = "${use_config_path}/glassfish${config_v}/glassfish/bin"

  exec { 'restart_glassfish_service':
    command     => "/etc/init.d/${service_name}_${domain} restart",
    refreshonly =>  true,
  }
  # glassfish containment
  contain ::glassfish::config
  contain ::glassfish::service
  # configuring glassfish
  include ::glassfish::config
}
