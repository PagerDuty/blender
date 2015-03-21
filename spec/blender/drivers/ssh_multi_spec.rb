require 'spec_helper'

describe Blender::Driver::SshMulti do
  it '#DSL' do
    hosts = %w(a b c d)
    channel = double('channel').as_null_object
    session = double('session', open_channel: channel, loop: true)
    hosts.each do |h|
      expect(session).to receive(:use).with('foo@'+h, password: 'bar')
    end
    expect(Net::SSH::Multi).to receive(:start).and_return(session)
    sched = Blender::Scheduler.new('test')
    sched.config(:ssh_multi, user: 'foo', password: 'bar')
    sched.strategy :per_task
    sched.ssh_task 'run' do
      execute 'sudo /usr/local/sbin/chef-client-cron'
      members(hosts)
      concurrency 2
    end
    sched.run
  end
end
