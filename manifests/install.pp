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
  $package_source   = $::glassfish::use_package_source,
  $config_ensure    = $::glassfish::use_config_ensure,
  $config_path      = $::glassfish::use_config_path,
) {
  #archive module is used to download and extract the installer
  include ::archive

  file { 'glassfish_config' :
    ensure => $config_ensure,
    path   => $config_path,
  }
  archive { $package_name:
    ensure       => $package_ensure,
    path         => "/tmp/${package_name}",
    source       => $package_source,
    extract      => true,
    extract_path => "${config_path}/",
    cleanup      => false,
    require      => File[$config_path],
  }
}
