# glassfish::service
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include glassfish::service
class glassfish::service inherits glassfish {
  # create service glassfish
  service { 'glassfish':
    ensure  => $::glassfish::service_ensure,
    name    => 'glassfish_domain1',
    start   => '/etc/init.d/glassfish_domain1 start',
    stop    => '/etc/init.d/glassfish_domain1 stop',
    restart => '/etc/init.d/glassfish_domain1 restart',
  }
}
