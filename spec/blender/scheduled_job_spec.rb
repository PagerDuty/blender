require 'spec_helper'
require 'blender/scheduled_job'

describe Blender::ScheduledJob do
  let(:scheduled_job) do
    Blender::ScheduledJob.new('test job')
  end
  it '#blender_file' do
    scheduled_job.blender_file('test.rb')
    expect(scheduled_job.file).to eq('test.rb')
  end
  it '#cron' do
    time = '*/4 * * * *'
    scheduled_job.cron(time)
    expect(scheduled_job.schedule).to eq([:cron, time])
  end
  it '#every' do
    scheduled_job.every(15)
    expect(scheduled_job.schedule).to eq([:every, 15])
  end
  it '#run' do
    scheduled_job.blender_file('test.rb')
    scheduled_job.every(15)
    sched = double(Blender::Scheduler)
    expect(sched).to receive(:task).with('x')
    expect(File).to receive(:read).with('test.rb').and_return('task "x"')
    expect(Blender).to receive(:blend).with('test.rb').and_yield(sched)
    scheduled_job.run
  end
end
