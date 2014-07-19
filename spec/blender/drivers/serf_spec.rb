require 'spec_helper'
require 'blender/handlers/base'

describe Blender::Driver::Serf do
  let(:driver) do
    described_class.new(
      events: Blender::Handlers::Base.new,
      host: 'foo',
      port: 123,
      authkey: 'xyz'
    )
  end
  let(:tag_driver) do
    described_class.new(
      events: Blender::Handlers::Base.new,
      host: 'foo',
      port: 123,
      authkey: 'xyz',
      filter_by: :tag,
      filter_tag: 'fake-tag'
    )
  end
  let(:hosts) {['h1']}
  let(:tasks){ Array.new(3){|n| create_serf_task("t#{n}")}}
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
    driver.execute(tasks, hosts)
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
    tag_driver.execute(tasks, hosts)
  end
end
