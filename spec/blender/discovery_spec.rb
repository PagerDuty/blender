require 'spec_helper'
require 'blender/discovery'
describe Blender::Scheduler do

  let(:scheduler) do
    Blender::Scheduler.new('test')
  end

  it 'should return Chef is type :chef is passed' do
    class Blender::Discovery::Foo;end
    disco = double(Blender::Discovery::Foo)
    allow(disco).to receive(:search).with('name:xx').and_return(['a', 'b', 'c'])
    allow(Blender::Discovery::Foo).to receive(:new).and_return(disco)
    expect(scheduler.search(:foo, 'name:xx')).to eq(['a', 'b', 'c'])
  end
end
