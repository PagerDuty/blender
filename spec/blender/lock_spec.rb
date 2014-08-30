require 'spec_helper'
require 'timeout'
require 'thread'

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
        sleep 5
      end
    end

    s2 = Blender::Scheduler.new('test-1')
    s2.members(['localhost'])
    s2.ruby_task('date') do
      execute do
        puts "Nothing"
      end
    end
    t = Thread.new do
      s1.run
    end

    expect do
      Timeout.timeout(2) do
        s2.run
      end
    end.to raise_error(Timeout::Error)
    t.join
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

    t = Thread.new do
      s1.run
    end

    expect do
      Timeout.timeout(2) do
        s2.run
      end
    end.not_to raise_error
    t.join
  end
end
