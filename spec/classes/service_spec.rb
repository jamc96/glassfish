require 'spec_helper'

describe 'glassfish::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { { :os => { 'family' => 'RedHat', 'name' => 'CentOS', 'architecture' => 'x86_64'}, :kernel => 'Linux',} }

      # default compilation without dependency cicle
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
      # ensure service running
      it {
        is_expected.to contain_service('glassfish').with(
            ensure: 'running',
            name: 'glassfish_domain1',
            start: '/etc/init.d/glassfish_domain1 start',
            stop: '/etc/init.d/glassfish_domain1 stop',
            restart: '/etc/init.d/glassfish_domain1 restart',
        )
      }
    end
  end
end
