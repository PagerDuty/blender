require 'spec_helper'

describe Blender::Driver::Ssh do
  let(:driver) {described_class.new(events: Object.new)}
  let(:job) do
    Blender::Job.new(
      101,
      nil,
      %w{h1},
      Array.new(3){|n| create_task("t#{n}")}
    )
  end
  it 'should execute commands over net ssh channel' do
    channel = double('channel').as_null_object
    session = double('session', open_channel: channel, loop: true)
    expect(Net::SSH).to receive(:start).with(
      'h1',
      ENV['USER'],
      {password: nil}
    ).and_return(session)
    driver.execute(job)
  end
end
