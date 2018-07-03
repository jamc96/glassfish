require 'spec_helper'

describe 'glassfish::create_daemon' do
  let(:title) { 'tunning' }
  let(:params) { { 'asadmin_path' => '/opt/glassfish-4.1/glassfish4/bin' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/etc/init.d/glassfish_domain1').with(ensure: 'present', mode: '0775') }
    end
  end
end
