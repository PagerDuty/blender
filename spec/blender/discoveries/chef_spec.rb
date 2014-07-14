require 'spec_helper'

describe Blender::Discovery::ChefDiscovery do
  let(:discovery){described_class.new}
  it '#search' do
    query = double(Chef::Search::Query)
    node = Chef::Node.new
    node.set['fqdn'] = 'a'
    expect(query).to receive(:search).with(:node, '*:*').and_return([[node]])
    expect(Chef::Search::Query).to receive(:new).and_return(query)
    expect(discovery.search).to eq(['a'])
  end
end
