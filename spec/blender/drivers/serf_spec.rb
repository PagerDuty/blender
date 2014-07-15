require 'spec_helper'

describe Blender::Driver::Serf do
  let(:driver) do
    described_class.new(
      events: Object.new,
      host: 'foo',
      port: 123,
      authkey: 'xyz'
    )
  end
  let(:tag_driver) do
    described_class.new(
      events: Object.new,
      host: 'foo',
      port: 123,
      authkey: 'xyz',
      filter_by: :tag,
      filter_tag: 'fake-tag'
    )
  end
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
    conn_opts = { host: 'foo', port: 123, authkey: 'xyz'}
    query_opts = [
      'test-query',
      'test-payload',
      {:FilterNodes=>["h1"], :Timeout=>15000000000}
    ]
    expect(conn).to receive(:query).with(*query_opts).and_yield(Object.new).exactly(3).times
    expect(Serfx).to receive(:connect).with(conn_opts).and_yield(conn).exactly(3).times
    driver.execute(job)
  end

  it '#execute serf query based on tags' do
    conn = double('connection')
    conn_opts = { host: 'foo', port: 123, authkey: 'xyz'}
    query_opts = [
      'test-query',
      'test-payload',
      { FilterTags: {"fake-tag"=>"h1"}, :Timeout=>15000000000}
    ]
    expect(conn).to receive(:query).with(*query_opts).and_yield(Object.new).exactly(3).times
    expect(Serfx).to receive(:connect).with(conn_opts).and_yield(conn).exactly(3).times
    tag_driver.execute(job)
  end
end
