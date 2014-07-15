require 'spec_helper'

describe Blender::Driver::SshMulti do
  let(:driver) {described_class.new(events: Object.new, concurrency: 10)}
  let(:job) do
    Blender::Job.new(
      101,
      nil,
      %w{h1 h2 h3 h4 h5},
      Array.new(1){|n| create_task("t#{n}")}
    )
  end
  it '#concurrency' do
    expect(driver.concurrency).to eq(10)
  end
end
