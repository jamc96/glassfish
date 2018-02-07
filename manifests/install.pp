# glassfish::install
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::install
class glassfish::install(
  $package_ensure   = $::glassfish::use_package_ensure,
  $package_name     = $::glassfish::use_package_name,
  $package_provider = $::glassfish::use_package_provider,
  $package_source   = $::glassfish::use_package_source,
  $package_type     = $::glassfish::package_type,
  $config_ensure    = $::glassfish::use_config_ensure,
  $config_path      = $::glassfish::use_config_path,
) {
  #archive module is used to download and extract the installer
  include ::archive

  package { 'glassfish_provider':
    ensure => $package_ensure,
    name   => $package_provider,
  }
  file { 'glassfish_config' :
    ensure  => $config_ensure,
    path    => $config_path,
    require => Package['glassfish_provider'],
  }
  archive { $package_name :
    ensure    => $package_ensure,
    url       => $package_source,
    target    => $config_path,
    extension => $package_type,
  }
}
