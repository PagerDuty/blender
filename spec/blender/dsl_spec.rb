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

  context '#scp' do
    it '#upload' do
      session = double('Net::SSH::Session', loop: true)
      scp = double('Net::SSH::Scp')
      expect(Net::SSH).to receive(:start).with('host1', 'x', password: 'y').and_return(session)
      expect(session).to receive(:scp).and_return(scp)
      expect(scp).to receive(:upload!).with('/local/path', '/remote/path')
      Blender.blend('test') do |sched|
        sched.config(:scp, user: 'x', password: 'y')
        sched.members(['host1'])
        sched.scp_upload '/remote/path' do
          from '/local/path'
        end
      end
    end
    it '#download' do
      session = double('Net::SSH::Session', loop: true)
      scp = double('Net::SSH::Scp')
      expect(Net::SSH).to receive(:start).with('host1', 'x', password: 'y').and_return(session)
      expect(session).to receive(:scp).and_return(scp)
      expect(scp).to receive(:download!).with('/remote/path', '/local/path')
      Blender.blend('test') do |sched|
        sched.members(['host1'])
        sched.config(:scp, user: 'x', password: 'y')
        sched.scp_download '/remote/path' do
          to '/local/path'
        end
      end
    end
  end
end
