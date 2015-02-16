require 'spec_helper'

describe Blender do
  it 'passes scp options' do
    sched = Blender::Scheduler.new('scp')
    sched.scp_upload 'foo' do
      recursive true
      from '/tmp/from'
      to '/tmp/to'
    end
    task = sched.tasks.first
    expect(task.command.target).to eq('/tmp/to')
    expect(task.command.source).to eq('/tmp/from')
    expect(task.command.options[:recursive]).to eq(true)
    expect(task.command.direction).to eq(:upload)
  end
end
