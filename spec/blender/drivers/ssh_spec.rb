require 'spec_helper'

describe Blender::Driver::Ssh do
  let(:hosts) {['h1']}
  let(:tasks){ Array.new(3){|n| create_task("t#{n}")}}
  let(:driver) {described_class.new(events: Object.new)}

  it 'executes commands over net ssh channel' do
    channel = double('channel').as_null_object
    session = double('session', open_channel: channel, loop: true)
    expect(Net::SSH).to receive(:start).with(
      'h1',
      ENV['USER'],
      {}
    ).and_return(session)
    driver.execute(tasks, hosts)
  end

  it 'gives readable error message on failure' do
    err_msg = 'Custom failure message via STDERR'
    channel = double('channel', wait: true, request_pty: true, on_data: true, on_request: true)
    allow(channel).to receive(:exec).and_yield(channel, false)
    allow(channel).to receive(:on_extended_data).and_yield(channel, nil, err_msg)
    session = double('session',loop: true)
    allow(session).to receive(:open_channel).and_yield(channel).and_return(channel)
    expect(Net::SSH).to receive(:start).with(
      'h1',
      ENV['USER'],
      {}
    ).and_return(session)
    expect do
      driver.execute(tasks, hosts)
    end.to raise_error(Blender::ExecutionFailed, err_msg)
  end
end
