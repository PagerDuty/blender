require 'spec_helper'

describe Blender::Driver::Serf do
  let(:driver) {described_class.new(events: Object.new)}
  let(:job) do
    Blender::Job.new(
      101,
      nil,
      %w{h1},
      Array.new(3){|n| create_serf_task("t#{n}")}
    )
  end
  it '#execute serf query' do
    conn = double('connection')
    expect(conn).to receive(:query).and_yield(Object.new).exactly(3).times
    expect(Serfx).to receive(:connect).and_yield(conn).exactly(3).times
    driver.execute(job)
  end
end
