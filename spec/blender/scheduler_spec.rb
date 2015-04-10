require 'spec_helper'

describe Blender::Scheduler do
  let(:scheduler) do
    described_class.new('test')
  end
  context 'members' do
    it 'assign target hosts from the dsl method' do
      scheduler.members(%w(foo bar baz))
      expect(scheduler.metadata[:members]).to eq(%w(foo bar baz))
    end
    it 'convers scalar values to array' do
      scheduler.members('foo')
      expect(scheduler.metadata[:members]).to eq(['foo'])
    end
  end
  describe '#no_doc' do
    it 'does not use document handler if no_doc option is passed' do
      expect(Blender::Handlers::Doc).to_not receive(:new)
      task = Blender::Task::Ruby.new('test')
      sched = described_class.new('no_doc', [] , no_doc: true)
      sched.run
    end
  end
  describe '#DSL' do
    subject(:task){scheduler.tasks.first}
    it '#ask' do
      tui = double(HighLine)
      allow(HighLine).to receive(:new).and_return(tui)
      expect(tui).to receive(:ask).with('foo')
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
      it 'belong to base class' do
        expect(task).to be_kind_of(Blender::Task::Base)
      end
      it 'use shellout driver' do
        expect(task.driver).to be_kind_of(Blender::Driver::ShellOut)
      end
      it 'contain only one task' do
        expect(scheduler.tasks.size).to eq(1)
      end
    end
    describe '#ssh_task' do
      before do
        scheduler.ssh_task('test') do
          members ['a']
          execute('ls -l')
        end
      end
      it 'have correct hosts list' do
        expect(task.hosts).to eq(['a'])
      end
      it 'have correct command' do
        expect(task.command).to eq('ls -l')
      end
      it 'use ssh task subclass' do
        expect(task).to be_kind_of(Blender::Task::Ssh)
      end
      it 'use the ssh driver' do
        expect(task.driver).to be_kind_of(Blender::Driver::Ssh)
      end
    end
    describe '#on' do
      it 'invoke custom block on specific events', fork: true do
        test = 1
        Blender.blend('do it') do |sched|
          sched.on :run_finished do |x|
            test = 2
          end
          sched.task 'ls -alh'
        end
        expect(test).to eq(2)
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
      it 'setup correct hosts' do
        expect(task.hosts).to eq(['c'])
      end
      it 'uses the ruby task subclass' do
        expect(task).to be_kind_of(Blender::Task::Base)
      end
      it 'assigns the proc as command' do
        expect(task.command).to be_kind_of(Proc)
      end
      it 'assign ruby driver subclass' do
        expect(task.driver).to be_kind_of(Blender::Driver::Ruby)
      end
    end
    describe '#strategy' do
      it 'raise error for non-existent strategy' do
        expect do
          scheduler.strategy(:foo)
        end.to raise_error(Blender::UnknownSchedulingStrategy)
      end
      it '#get default' do
        expect(scheduler.strategy(:default)).to be_kind_of(Blender::SchedulingStrategy::Default)
      end
      it '#get per_host' do
        expect(scheduler.strategy(:per_host)).to be_kind_of(Blender::SchedulingStrategy::PerHost)
      end
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
      d = scheduler.driver(:ssh, foo: :bar)
      expect(d).to be_kind_of(Blender::Driver::Ssh)
      expect(d.config[:foo]).to be(:bar)
    end
    it 'has no tasks' do
      expect(scheduler.tasks).to be_empty
    end
    it 'has no hosts' do
      expect(scheduler.metadata[:members]).to be_empty
    end
    describe '#run' do
      it 'uses serial_run when concurrency is not set' do
        expect(scheduler).to receive(:serial_run)
        scheduler.task 'echo HelloWorld'
        scheduler.run
      end
      it 'uses concurrent_run when concurrency is used' do
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
