require 'spec_helper'

describe 'glassfish::asadmin' do
  let(:title) { 'namevar' }
  let(:params) { { 'asadmin_path' => '/opt/glassfish-4.1/glassfish4/bin' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
