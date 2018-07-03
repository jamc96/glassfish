require 'spec_helper'

describe 'glassfish::config' do
  let(:facts) { { os: { 'family' => 'RedHat', 'name' => 'CentOS', 'architecture' => 'x86_64' }, kernel: 'Linux' } }

  on_supported_os.each do |os, _os_facts|
    context "on #{os}" do
      # check compilation
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # root directory
      it { is_expected.to contain_file('/opt/glassfish-4.1').that_requires('User[glassfish]') }
      # download glassfish installer
      it { is_expected.to contain_archive('glassfish-4.1.zip').that_requires('File[/opt/glassfish-4.1]') }
      # symbolink link to bin path
      it { is_expected.to contain_file('/home/glassfish/bin').that_requires('Archive[glassfish-4.1.zip]') }
      # remove empty links on installation
      it { is_expected.to contain_file('/usr/bin/asadmin').that_requires('File[/home/glassfish/bin]') }
      # create service binary file
      it { is_expected.to contain_glassfish__create_daemon('glassfish').that_requires('Archive[glassfish-4.1.zip]') }
      # ensure master and asadmin password files
      it { is_expected.to contain_file('/home/glassfish/.as_master_pass').that_requires('Glassfish::Create_daemon[glassfish]').that_notifies('Exec[change_master_password]') }
      it { is_expected.to contain_file('/home/glassfish/.as_admin_pass').that_requires('Glassfish::Create_daemon[glassfish]').that_notifies('Exec[change_admin_password]') }
      # change master password
      it { is_expected.to contain_exec('change_master_password').that_notifies('Exec[start_glassfish_service]') }
      # change admin password
      it { is_expected.to contain_exec('change_admin_password').that_notifies('Exec[enable_secure_admin]') }
      # enable secure admin and restart service
      it { is_expected.to contain_exec('enable_secure_admin').that_notifies(['Exec[restart_glassfish_service]', 'Exec[set_admin_listener_port]']) }
      # admin listener port
      it { is_expected.to contain_exec('set_admin_listener_port').that_notifies('Exec[set_secure_port]') }
      # secure port
      it { is_expected.to contain_exec('set_secure_port').that_notifies('Exec[stop_java]') }
      # refresh service
      it { is_expected.to contain_exec('stop_java').that_notifies('Exec[refresh_glassfish_service]') }
    end
  end
  context 'default password files' do
    it {
      is_expected.to contain_file('/home/glassfish/.as_master_pass') \
        .with_content(%r{^AS_ADMIN_NEWMASTERPASSWORD=changeit})
    }
    it {
      is_expected.to contain_file('/home/glassfish/.as_admin_pass') \
        .with_content(%r{^AS_ADMIN_PASSWORD=admin})
    }
  end
end
