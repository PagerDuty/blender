require 'spec_helper'
describe Blender::Scheduler do

  let(:scheduler) do
    Blender::Scheduler.new('test')
  end
  it 'should return Chef is type :chef is passed' do
    allow_any_instance_of(Blender::Discovery::Chef).to(
      receive(:search).and_return(['a', 'b', 'c'])
    )
    expect(scheduler.chef_nodes(search: 'name:xx')).to eq(['a', 'b', 'c'])
  end
  it 'should return SerfDiscover is type :serf is passed' do
    allow_any_instance_of(Blender::Discovery::Serf).to(
      receive(:search).and_return([1, 2, 3])
    )
    expect(scheduler.serf_nodes).to eq([1,2,3])
  end
end
