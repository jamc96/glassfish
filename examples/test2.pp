# second test case
#
#
# createing user/group glassfish
group { 'glassfish':
  gid => '2100',
}
user { 'glassfish':
  ensure  => present,
  comment => 'Managed by Puppet',
  home    => '/home/glassfish',
  shell   => '/bin/bash',
  uid     => '2100',
  gid     => '2100',
  require => Group['glassfish'],
}
# adding relationship between user and class
User['glassfish'] -> Class['glassfish']
# install, configure and manage service
class { '::glassfish':
  manage_user => false,
}
