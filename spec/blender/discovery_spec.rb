require 'spec_helper'
describe Blender::Scheduler do

  let(:scheduler) do
    Blender::Scheduler.new('test')
  end
  it 'should return Chef is type :chef is passed' do
    allow_any_instance_of(Blender::Discovery::Chef).to(
      receive(:search).and_return(['a', 'b', 'c'])
    )
    expect(scheduler.chef_discover(search: 'name:xx')).to eq(['a', 'b', 'c'])
  end
  it 'should return SerfDiscover is type :serf is passed' do
    allow_any_instance_of(Blender::Discovery::Serf).to(
      receive(:search).and_return([1, 2, 3])
    )
    expect(scheduler.serf_discover).to eq([1,2,3])
  end
  it '#register_discovery' do
    scheduler.register_discovery(:chef, 'test')
    expect(scheduler.registered_discoveries['test']).to be_kind_of(Blender::Discovery::Chef)
  end
  it '#discover_by' do
    allow_any_instance_of(Blender::Discovery::Chef).to(
      receive(:search).and_return(['x', 'y', 'z'])
    )
    scheduler.register_discovery(:chef, 'test')
    expect(scheduler.discover_by('test')).to eq(['x', 'y', 'z'])
  end
end
