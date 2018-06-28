require 'spec_helper'

describe 'glassfish::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # default compilation without dependency cicle
      it { is_expected.to compile }
      # ensure service running
      it { is_expected.to contain_service('glassfish').with(
        :ensure  => 'running',
        :name    => 'glassfish_domain1',
        :start   => '/etc/init.d/glassfish_domain1 start',
        :stop    => '/etc/init.d/glassfish_domain1 stop',
        :restart => '/etc/init.d/glassfish_domain1 restart',
        )
      }
    end
  end
end
