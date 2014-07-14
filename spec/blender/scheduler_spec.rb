require 'spec_helper'

describe Blender::Scheduler do
  let(:scheduler) do
    described_class.new('test')
  end
  describe '#DSL' do
    subject(:task){scheduler.tasks.first}
    it '#ask' do
      tui = double(HighLine)
      expect(tui).to receive(:ask).with('foo')
      expect(HighLine).to receive(:new).and_return(tui)
      scheduler.ask('foo')
    end
    it '#register_handler' do
      handler = Object.new
      scheduler.register_handler(handler)
      expect(scheduler.events.handlers).to include(handler)
    end
    describe '#task' do
      before do
        scheduler.task('whoa')
      end
      it 'should belong to base class' do
        expect(task).to be_kind_of(Blender::Task::Base)
      end
      it 'should use shellout driver' do
        expect(task.driver).to be_kind_of(Blender::Driver::ShellOut)
      end
      it 'should contain only one task' do
        expect(scheduler.tasks.size).to eq(1)
      end
    end
    describe '#ssh_task' do
      before do
        scheduler.ssh_task('test') do |t|
          t.members ['a']
          t.execute('ls -l')
        end
      end
      it 'should have correct hosts list' do
        expect(task.hosts).to eq(['a'])
      end
      it 'should have correct command' do
        expect(task.command).to eq('ls -l')
      end
      it 'should use ssh task subclass' do
        expect(task).to be_kind_of(Blender::Task::SSHTask)
      end
      it 'should use the ssh driver' do
        expect(task.driver).to be_kind_of(Blender::Driver::Ssh)
      end
    end
    describe'#serf_task' do
      before do
        scheduler.serf_task('test') do |t|
          t.members ['b']
          t.query 'foo'
          t.payload 'bar'
          t.no_ack true
        end
      end
      it 'should have correct host list' do
        expect(task.hosts).to eq(['b'])
      end
      it 'should use the serf task subclass' do
        expect(task).to be_kind_of(Blender::Task::SerfTask)
      end
      it 'should use the serquery inner class for command' do
        expect(task.command).to be_kind_of(Blender::Task::SerfTask::SerfQuery)
      end
      it 'should use serf driver subclass' do
        expect(task.driver).to be_kind_of(Blender::Driver::Serf)
      end
      it 'should allow setting up serf query and payload' do
        expect(task.command.query).to eq('foo')
        expect(task.command.payload).to eq('bar')
      end
    end
    describe '#ruby_task' do
      before do
        scheduler.ruby_task('test') do |t|
          t.members ['c']
          t.execute do
            raise 'Fail'
          end
        end
      end
      it 'should setup correct hosts' do
        expect(task.hosts).to eq(['c'])
      end
      it 'should use the ruby task subclass' do
        expect(task).to be_kind_of(Blender::Task::RubyTask)
      end
      it 'should assign the proc as command' do
        expect(task.command).to be_kind_of(Proc)
      end
      it 'should the ruby driver subclass' do
        expect(task.driver).to be_kind_of(Blender::Driver::Ruby)
      end
    end
    it '#strategy' do
      expect(Blender::SchedulingStrategy).to receive(:get).with(:foo)
      scheduler.strategy(:foo)
    end
    it '#concurrency' do
      scheduler.concurrency(112)
      expect(scheduler.metadata[:concurrency]).to be(112)
    end
    it '#ignore_failure' do
      scheduler.ignore_failure true
      expect(scheduler.metadata[:ignore_failure]).to be(true)
    end
    it '#members' do
      scheduler.members(['a', 'b'])
      expect(scheduler.metadata[:members]).to eq(['a', 'b'])
    end
    it '#driver' do
      scheduler.driver(:ssh) do |config|
        config[:foo] = :bar
      end
      d = scheduler.default_driver
      expect(d).to be_kind_of(Blender::Driver::Ssh)
      expect(d.config[:foo]).to be(:bar)
    end
    it '#register_driver' do
      scheduler.register_driver(:serf, 'foo', host: '8.8.8.8')
      d = scheduler.registered_drivers['foo']
      expect(d).to be_kind_of(Blender::Driver::Serf)
    end
    it 'should have no tasks' do
      expect(scheduler.tasks).to be_empty
    end
    it 'should have no hosts' do
      expect(scheduler.metadata[:members]).to eq(['localhost'])
    end
    describe '#run' do
      it 'should use serial_run when concurrency is not set' do
        expect(scheduler).to receive(:serial_run)
        scheduler.task 'echo HelloWorld'
        scheduler.run
      end
      it 'should use concurrent_run when concurrency is used' do
        expect(scheduler).to receive(:concurrent_run)
        scheduler.task 'echo HelloWorld1'
        scheduler.task 'echo HelloWorld2'
        scheduler.task 'echo HelloWorld3'
        scheduler.concurrency(2)
        scheduler.run
      end
    end
  end
end
