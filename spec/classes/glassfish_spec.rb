require 'spec_helper'

describe 'glassfish' do
  let(:facts) { { os: { 'family' => 'RedHat', 'name' => 'CentOS', 'architecture' => 'x86_64' }, kernel: 'Linux' } }

  context 'with default parameters' do
    # validate if user and group exist
    it { is_expected.to contain_group('glassfish').with(gid: '2100') }
    it {
      is_expected.to contain_user('glassfish').with(
        ensure: 'present',
        comment: 'Managed by Puppet',
        home: '/home/glassfish',
        uid: '2100',
        gid: '2100',
      )
    }
    it { is_expected.to contain_user('glassfish').that_requires('Group[glassfish]') }
    # validate if java is installed
    it {
      is_expected.to contain_java__oracle('jdk8').with(
        ensure: 'present',
        version: '8',
        java_se: 'jdk',
      )
    }
    # class containment
    it { is_expected.to contain_class('glassfish::config') }
    it { is_expected.to contain_class('glassfish::service') }
    # root directory
    it {
      is_expected.to contain_file('/opt/glassfish-4.1').with(
        ensure: 'directory',
        owner: 'glassfish',
        group: 'glassfish',
        selinux_ignore_defaults: true,
      )
    }
    # ensure package has been downloaded
    it {
      is_expected.to contain_archive('glassfish-4.1.zip').with(
        ensure: 'present',
        path: '/home/glassfish/glassfish-4.1.zip',
        source: 'http://download.oracle.com/glassfish/4.1/release/glassfish-4.1.zip',
        extract: true,
        extract_path: '/opt/glassfish-4.1/',
        cleanup: false,
        user: 'glassfish',
        group: 'glassfish',
      )
    }
    # symbolink link to bin path
    it {
      is_expected.to contain_file('/home/glassfish/bin').with(
        ensure: 'link',
        target: '/opt/glassfish-4.1/glassfish4/bin',
      )
    }
    # remove empty links on installation
    it {
      is_expected.to contain_file('/usr/bin/asadmin').with(
        ensure: 'absent',
      )
    }
    # create service binary file
    it {
      is_expected.to contain_glassfish__create_daemon('glassfish').with(
        asadmin_path: '/opt/glassfish-4.1/glassfish4/glassfish/bin',
        domain: 'domain1',
        port: '4848',
      )
    }
    # ensure master and asadmin password files
    it {
      is_expected.to contain_file('/home/glassfish/.as_master_pass').with(
        ensure: 'file',
        mode: '0644',
        notify: 'Exec[change_master_password]',
      )
    }
    it {
      is_expected.to contain_file('/home/glassfish/.as_admin_pass').with(
        ensure: 'file',
        mode: '0644',
        notify: 'Exec[change_admin_password]',
      )
    }
    # change master password
    it {
      is_expected.to contain_exec('change_master_password').with(
        command:  '/opt/glassfish-4.1/glassfish4/glassfish/bin/asadmin change-master-password --passwordfile=/home/glassfish/.as_master_pass --savemasterpassword',
        refreshonly:  true,
        notify: 'Exec[start_glassfish_service]',
      )
    }
    # change admin password
    it {
      is_expected.to contain_exec('change_admin_password').with(
        command:  '/opt/glassfish-4.1/glassfish4/glassfish/bin/asadmin --user admin --passwordfile=/home/glassfish/.as_admin_pass change-admin-password',
        refreshonly:  true,
        notify: 'Exec[enable_secure_admin]',
      )
    }
    # enable secure admin and restart service
    it {
      is_expected.to contain_exec('enable_secure_admin').with(
        command: '/opt/glassfish-4.1/glassfish4/glassfish/bin/asadmin enable-secure-admin --passwordfile=/home/glassfish/.as_admin_pass',
        refreshonly: true,
      )
    }
  end
  context 'with different admin/master password' do
    let(:params) { { 'as_admin_master_password' => 'admin1234', 'as_admin_password' => 'changeit1234' } }

    it {
      is_expected.to contain_file('/home/glassfish/.as_master_pass') \
        .with_content(%r{^AS_ADMIN_NEWMASTERPASSWORD=admin1234})
    }
    it {
      is_expected.to contain_file('/home/glassfish/.as_admin_pass') \
        .with_content(%r{^AS_ADMIN_PASSWORD=changeit1234})
    }
  end
  context 'with service_ensure => stopped' do
    let(:params) { { 'service_ensure' => 'stopped' } }

    it {
      is_expected.to contain_service('glassfish').with(
        ensure: 'stopped',
        name: 'glassfish_domain1',
        start: '/etc/init.d/glassfish_domain1 start',
        stop: '/etc/init.d/glassfish_domain1 stop',
        restart: '/etc/init.d/glassfish_domain1 restart',
      )
    }
  end
  context 'whith version => latest' do
    let(:params) { { 'version' => 'latest' } }

    # root directory
    it { is_expected.to contain_file('/opt/glassfish-5.0').that_requires('User[glassfish]') }
    # download glassfish installer
    it { is_expected.to contain_archive('glassfish-5.0.zip').that_requires('File[/opt/glassfish-5.0]') }
    # symbolink link to bin path
    it { is_expected.to contain_file('/home/glassfish/bin').that_requires('Archive[glassfish-5.0.zip]') }
    # remove empty links on installation
    it { is_expected.to contain_file('/usr/bin/asadmin').that_requires('File[/home/glassfish/bin]') }
    # create service binary file
    it { is_expected.to contain_glassfish__create_daemon('glassfish').that_requires('Archive[glassfish-5.0.zip]') }
  end
end
