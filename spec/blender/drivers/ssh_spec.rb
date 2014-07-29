require 'spec_helper'

describe Blender::Driver::Ssh do
  let(:hosts) {['h1']}
  let(:tasks){ Array.new(3){|n| create_task("t#{n}")}}
  let(:driver) {described_class.new(events: Object.new)}
  it 'should execute commands over net ssh channel' do
    channel = double('channel').as_null_object
    session = double('session', open_channel: channel, loop: true)
    expect(Net::SSH).to receive(:start).with(
      'h1',
      ENV['USER'],
      {}
    ).and_return(session)
    driver.execute(tasks, hosts)
  end
end
