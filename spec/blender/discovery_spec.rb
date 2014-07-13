require 'spec_helper'
describe Blender::Discovery do
  let(:dummy_hosts) {['host1', 'host2', 'host3']}
  let(:scheduler) do
    Blender::Scheduler.new('test')
  end
  let(:chef_discovery) do
    Blender::Discovery::ChefDiscovery
  end
  let(:serf_discovery) do
    Blender::Discovery::SerfDiscovery
  end
  it 'should return ChefDiscover is type :chef is passed' do
    expect(described_class.get(:chef)).to eq(chef_discovery)
  end
  it 'should return SerfDiscover is type :serf is passed' do
    expect(described_class.get(:serf)).to eq(serf_discovery)
  end
  it '#register_discovery' do
    scheduler.register_discovery(:chef, 'test')
    expect(scheduler.registered_discoveries['test']).to be_kind_of(chef_discovery)
  end
  it '#discover_by' do
    scheduler.register_discovery(:chef, 'test')
    allow(scheduler.registered_discoveries['test']).to receive(:search).and_return(dummy_hosts)
    expect(scheduler.discover_by('test')).to eq(dummy_hosts)
  end
  it '#discover' do
    dummy_discovery = double(chef_discovery)
    expect(dummy_discovery).to receive(:search).and_return(dummy_hosts)
    expect(chef_discovery).to receive(:new).and_return(dummy_discovery)
    expect(scheduler.discover(:chef)).to eq(dummy_hosts)
  end
end
