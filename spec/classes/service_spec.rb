require 'spec_helper'

describe 'glassfish::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it {
        is_expected.to contain_service('glassfish').with(
          'name'      => 'glassfish',
          'ensure'    => 'running',
          'enable'    => 'true',
        )
      }
    end
  end
end
