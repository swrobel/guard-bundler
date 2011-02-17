# encoding: utf-8
require 'spec_helper'

describe Guard::Bundler do
  subject { Guard::Bundler.new }

  describe 'options' do

    context 'notify' do

      it 'should be true by default' do
        subject.should be_notify
      end

      it 'should be set to false' do
        subject = Guard::Bundler.new([], {:notify => false})
        subject.options[:notify].should be_false
      end

    end

  end

  context 'start' do

    it 'should call `bundle check\' command' do
      subject.should_receive(:`).with('bundle check')
      subject.should_receive(:system).with('bundle install')
      subject.start
    end

    it 'should call `bundle install\' command' do
      subject.should_receive(:bundle_need_refresh?).and_return(true)
      subject.should_receive(:system).with('bundle install').and_return(true)
      subject.start.should be_true
    end

    it 'should not call `bundle install\' command if update not needed' do
      subject.should_receive(:bundle_need_refresh?).and_return(false)
      subject.should_not_receive(:system).with('bundle install')
      subject.start.should be_true
    end

    it 'should return false if `bundle install\' command fail' do
      subject.should_receive(:bundle_need_refresh?).and_return(true)
      subject.should_receive(:system).with('bundle install').and_return(false)
      subject.start.should be_false
    end

  end

  context 'reload' do

    it 'should call `bundle install\' command' do
      subject.should_receive(:system).with('bundle install').and_return(true)
      subject.reload.should be_true
    end

    it 'should return false if `bundle install\' command fail' do
      subject.should_receive(:system).with('bundle install').and_return(false)
      subject.reload.should be_false
    end

  end

  context 'run_all' do

    it 'should return true' do
      subject.run_all.should be_true
    end

  end

  context 'run_on_change' do

    it 'should call `bundle check\' command' do
      subject.should_receive(:`).with('bundle check')
      subject.should_receive(:system).with('bundle install')
      subject.run_on_change
    end

    it 'should call `bundle install\' command if update needed' do
      subject.should_receive(:bundle_need_refresh?).and_return(true)
      subject.should_receive(:system).with('bundle install').and_return(true)
      subject.run_on_change.should be_true
    end

    it 'should not call `bundle install\' command if update not needed' do
      subject.should_receive(:bundle_need_refresh?).and_return(false)
      subject.should_not_receive(:system).with('bundle install')
      subject.run_on_change.should be_true
    end

    it 'should return false if `bundle install\' command fail' do
      subject.should_receive(:bundle_need_refresh?).and_return(true)
      subject.should_receive(:system).with('bundle install').and_return(false)
      subject.run_on_change.should be_false
    end

  end

  it 'should call notifier after `bundle install\' command success' do
    subject.should_receive(:system).with('bundle install').and_return(true)
    Guard::Bundler::Notifier.should_receive(:notify).with(true, anything())
    subject.send(:refresh_bundle)
  end

  it 'should call notifier after `bundle install\' command fail' do
    subject.should_receive(:system).with('bundle install').and_return(false)
    Guard::Bundler::Notifier.should_receive(:notify).with(true, anything())
    subject.send(:refresh_bundle)
  end

  it 'should not call notifier id notify option is set to false' do
    subject.stub(:notify?).and_return(false)
    subject.should_receive(:system).with('bundle install').and_return(true)
    Guard::Bundler::Notifier.should_not_receive(:notify)
    subject.send(:refresh_bundle)
  end

end