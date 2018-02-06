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
  Pattern[/zip|tar.gz|rpm/] $package_type   = 'zip',
  Optional[String] $package_name            = undef,
  String $package_source                    = 'http://download.oracle.com/glassfish',
  Pattern[/present|absent/] $config_ensure  = 'present',
  Optional[String] $config_path             = undef,
  ) {
# Global variables
  $use_version = $version ? {
    'latest' => '5.0.1',
    undef    => '4.1',
    default  => $version,
  }
  $use_config_path = $config_path ? {
    undef   => "/opt/glassfish-${use_version}",
    default => $config_path,
  }
  $use_package_name = $package_name ? {
    undef   => "glassfish${version}.${package_type}",
    default => $package_name,
  }

  class { '::glassfish::install': } -> Class['::glassfish']
}
