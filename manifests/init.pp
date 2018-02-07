# glassfish
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish
class glassfish(
  Optional[Pattern[/latest|^[.+_0-9:~-]+$/]] $version = undef,
  Pattern[/present|absent/] $package_ensure = 'present',
  Pattern[/zip|tar.gz/] $package_type       = 'zip',
  Optional[String] $package_name            = undef,
  Optional[String] $package_source          = undef,
  Pattern[/present|absent/] $config_ensure  = 'present',
  Optional[String] $config_path             = undef,
  ) {
# Global variables
  $use_version = $version ? {
    'latest' => '5.0.1',
    undef    => '4.1',
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
  class { '::glassfish::install': } -> Class['::glassfish']
}
