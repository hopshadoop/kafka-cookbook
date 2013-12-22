# encoding: utf-8

require 'spec_helper'

describe 'kafka::setup' do
  describe group('kafka') do
    it { should exist }
  end

  describe user('kafka') do
    it { should exist }
    it { should belong_to_group('kafka') }
    it { should have_home_directory('/home/kafka') }
    it { should have_login_shell('/bin/false') }
  end

  describe file('/opt/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/opt/kafka/config') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/var/log/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end

  describe file('/var/kafka') do
    it { should be_a_directory }
    it { should be_owned_by('kafka') }
    it { should be_grouped_into('kafka') }
    it { should be_mode 755 }
  end
end
