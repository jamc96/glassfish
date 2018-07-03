require 'spec_helper'

describe 'glassfish::asadmin' do
  let(:title) { 'namevar' }
  let(:params) { { 'asadmin_path' => '/opt/glassfish-4.1/glassfish4/bin' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # valide script file
      it {
        is_expected.to contain_file('/home/glassfish/configs.sh').with(
          ensure: 'file',
          owner: 'root',
          group: 'root',
          mode: '0500',
        )
      }
      # file validate_cmd attribute
      case os_facts[:operatingsystem]
      when 'CentOS'
        if os_facts[:operatingsystemmajrelease] == '7'
          it { is_expected.to contain_file('/home/glassfish/configs.sh').with(validate_cmd: '/usr/bin/sh -n %') }
        end
      else
        it { is_expected.to contain_file('/home/glassfish/configs.sh').with(validate_cmd: '/bin/sh -n %') }
      end
      # validate executions
      it { is_expected.to contain_file('/home/glassfish/configs.sh').that_notifies('Exec[/home/glassfish/configs.sh]') }
      # script execution
      it {
        is_expected.to contain_exec('/home/glassfish/configs.sh').with(
          command: 'sh /home/glassfish/configs.sh',
          refreshonly: true,
          path: '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
        )
      }
    end
  end
end
