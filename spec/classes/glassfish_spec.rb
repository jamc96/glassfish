require 'spec_helper'

describe 'glassfish' do
  let(:facts) { { :os => { 'family' => 'RedHat', 'name' => 'CentOS', 'architecture' => 'x86_64'}, :kernel => 'Linux',} }

  context 'on CentOS' do
    let(:params) { { } }
    
    # validate if user exist
    it {
      is_expected.to contain_user('glassfish').with(
        ensure: 'present',
        comment: 'Managed by Puppet',
        home: '/home/glassfish',
        uid: '2100',
        gid: '2100',
        require: 'Group[glassfish]',
      )
    }
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
        require: 'User[glassfish]',
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
        require: 'File[/opt/glassfish-4.1]',
      )
    }
  end
end
