require 'spec_helper'
require 'timeout'

describe Blender::Lock do

  let(:scheduler) do
    s = Blender::Scheduler.new('test')
    s.task('sleep 5')
    s
  end

  it 'should use Flock for locking by default' do
    expect(Blender::Configuration[:lock]['driver']).to eq('flock')
  end

  it 'should not allow two blender run with same name to run at the same time' do
    other = Blender::Scheduler.new('test')
    t = Thread.new do
      scheduler.run
    end
    other.task('sleep 1')
    expect do
      Timeout.timeout(3) do
        other.run
      end
    end.to raise_error(Timeout::Error)
    t.join
  end

  it 'should allow two blender run with different name to run at the same time' do
    t = Thread.new do
      scheduler.run
    end
    other = Blender::Scheduler.new('test1')
    other.task('sleep 1')
    expect do
      Timeout.timeout(3) do
        other.run
      end
    end.not_to raise_error
    t.join
  end
end
