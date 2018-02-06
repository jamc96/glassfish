# glassfish::install
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::install
class glassfish::install(
  $package_ensure  = $::mariadb::use_package_ensure,
  $package_name    = $::mariadb::use_package_name,
  $package_type    = $::mariadb::package_type,
  $package_source  = $::mariadb::package_source,
  $package_path    = $::mariadb::use_config_path,
  $package_version = $::mariadb::use_version,
) {
  case $package_type{
    'zip': {
      $install_command = "unzip ${package_name}"
    }
    'rpm': {
      $install_command = "rpm --force -iv ${package_name}"
    }
    default: {
      $install_command = "unzip ${package_name}"
    }
  }
  file { 'glassfish_config':
    ensure => directory,
    path   => $package_path,
  }
  file { 'glassfish_installer':
    ensure  => file,
    source  => $package_source,
    path    => "/tmp/${package_name}",
    require => File['glassfish_config'],
  }
  exec { "Install Glassfish version ${package_version}":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    command => $install_command,
    creates => $package_path,
    cwd     => '/tmp/',
    require => File['glassfish_installer'],
  }
}
