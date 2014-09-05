require 'spec_helper'

Thread.abort_on_exception = true

describe Blender::Lock do

  it 'should use Flock for locking by default' do
    expect(Blender::Configuration[:lock]['driver']).to eq('flock')
  end

  it 'should not allow two blender run with same name to run at the same time' do
    s1 = Blender::Scheduler.new('test-1')
    s1.members(['localhost'])
    s1.ruby_task('date') do
      execute do |h|
        puts "s1 start #{Time.now}"
        sleep 5
        puts "s1 finish #{Time.now}"
      end
    end

    s2 = Blender::Scheduler.new('test-1')
    s2.config(:ruby, stdout: $stdout)
    s2.members(['localhost'])

    s2.ruby_task('date') do
      execute do
        puts Dir['/tmp/*'].inspect
        puts "s2 finish #{Time.now}"
      end
    end

    pid = fork do
      s1.run
    end

    expect do
      s2.run
    end.to raise_error(Blender::LockAcquisitionError)
    status = Process.wait2 pid
    expect(status.last.exitstatus).to be_zero
  end

  it 'should allow two blender run with different name to run at the same time' do
    s1 = Blender::Scheduler.new('test-2')
    s1.members(['localhost'])
    s1.ruby_task('date') do
      execute do |h|
        sleep 5
      end
    end

    s2 = Blender::Scheduler.new('test-3')
    s2.members(['localhost'])
    s2.ruby_task('date') do
      execute do
        puts "Nothing"
      end
    end

    pid = fork do
      s1.run
    end

    expect do
      s2.run
    end.not_to raise_error
    status = Process.wait2 pid
    expect(status.last.exitstatus).to be_zero
  end
end
