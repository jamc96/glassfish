  # glassfish
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish
class glassfish(
  Pattern[/latest|^[.+_0-9:~-]+$/] $version = '4.1',
  Enum['present','absent'] $package_ensure  = 'present',
  Enum['directory','absent'] $config_ensure = 'directory',
  Enum['running','stopped'] $service_ensure = 'running',
  String $package_type                      = 'zip',
  Optional[String] $package_name            = undef,
  Optional[String] $package_source          = undef,
  Optional[String] $config_path             = undef,
  String $as_admin_user                     = 'admin',
  String $as_admin_password                 = 'admin',
  String $as_admin_master_password          = 'changeit',
  String $as_root_path                      = '/home/glassfish',
  String $service_name                      = 'glassfish',
  String $domain                            = 'domain1',
  Pattern[/^[0-9]+$/] $port                 = '4848',
  Pattern[/^[0-9]+$/] $secure_port          = '8181',
  Boolean $manage_user                      = true,
  Boolean $manage_java                      = true,
  Optional[Array] $asadmin_set              = undef,
  Optional[Array] $asadmin_create_managed   = undef,
  ) {
  # default variables
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
  $config_v = regsubst($use_version,'^(\d+)(\.(\d+)\.(\d+)|\.(\d+))$','\1')
  $asadmin_path = "${use_config_path}/glassfish${config_v}/glassfish/bin"

  # fake start of service
  exec { 'start_glassfish_service':
    command     => "/etc/init.d/${service_name}_${domain} start",
    refreshonly => true,
  }
  # fake restart of service
  exec { 'restart_glassfish_service':
    command     => "/etc/init.d/${service_name}_${domain} restart",
    refreshonly => true,
  }
  # manage glassfish user
  if $manage_user {
    group { 'glassfish':
      gid => '2100',
    }
    user { 'glassfish':
      ensure  => present,
      comment => 'Managed by Puppet',
      home    => '/home/glassfish',
      uid     => '2100',
      gid     => '2100',
      require => Group['glassfish'],
    }
  }
  # manage java installation
  if $manage_java {
    java::oracle { 'jdk8' :
      ensure  => 'present',
      version => '8',
      java_se => 'jdk',
    }
  }
  # glassfish containment
  contain ::glassfish::config
  contain ::glassfish::service
  # glassfish class relationship
  Class['::glassfish::config']
  ~> Class['::glassfish::service']
  # validate if array exist
  if $asadmin_set or $asadmin_create_managed {
    # apply tunning on glassfish 
    glassfish::asadmin { 'tunning':
      set            => $asadmin_set,
      create_managed => $asadmin_create_managed,
      asadmin_path   => "${asadmin_path}/asadmin",
      port           => $port,
      as_admin_user  => $as_admin_user,
    }
    # restart glassfish service after apply configuration
    Glassfish::Asadmin['tunning'] ~> Service['glassfish']
  }
}
