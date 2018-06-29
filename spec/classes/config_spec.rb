require 'spec_helper'

describe 'glassfish::config' do
  
  context "on RedHat" do
    let(:facts) { { :os => { 'family' => 'RedHat', 'name' => 'CentOS', 'architecture' => 'x86_64'}, :kernel => 'Linux',} }
    
    it { is_expected.to compile }
    it { is_expected.to compile.with_all_deps }
  end
end
