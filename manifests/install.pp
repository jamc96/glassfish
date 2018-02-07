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
  $package_path     = $::glassfish::use_config_path,
  $package_version  = $::glassfish::use_version,
) {
  #archive module is used to download and extract the installer
  include ::archive

  file { 'glassfish_config':
    ensure => directory,
    path   => $package_path,
  }
  Archive {
    provider => $package_provider,
  }
  archive { $package_name:
    path         => "/tmp/${package_name}",
    source       => $package_source,
    extract      => true,
    extract_path => "${package_path}/",
    cleanup      => true,
    require      => File[$package_path],
  }
}
