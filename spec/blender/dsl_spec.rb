require 'spec_helper'

describe '#dsl' do
  let(:scheduler) do
    sched = Blender::Scheduler.new('test')
    sched.instance_eval do
      ssh_task 'run' do
        execute 'sudo /usr/local/sbin/chef-client-cron'
        members ['a']
      end
    end
    sched
  end

  it '#check DSL' do
    allow_any_instance_of(Blender::Driver::Ssh).to receive(:execute)
    scheduler.run
  end
end
