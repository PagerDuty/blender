require 'spec_helper'
require 'blender/discoveries/chef'

describe Blender::Discovery::Chef do
  let(:discovery){described_class.new}
  it '#search' do
    query = double(Chef::Search::Query)
    node = Chef::Node.new
    node.set['fqdn'] = 'a'
    expect(query).to receive(:search).with(:node, '*:*').and_return([[node]])
    expect(Chef::Search::Query).to receive(:new).and_return(query)
    expect(discovery.search).to eq(['a'])
  end
  it '#search with options' do
    disco = described_class.new(
      config_file: 'foo.rb',
      node_name: 'bar',
      client_key: 'baz.rb',
      attribute: 'x.y.z'
    )
    query = double(Chef::Search::Query)
    node = Chef::Node.new
    node.set['x'] = { 'y' => { 'z' => 123 } }
    expect(Chef::Config).to receive(:from_file).with('foo.rb')
    expect(query).to receive(:search).with(:node, 'name:x').and_return([[node]])
    expect(Chef::Search::Query).to receive(:new).and_return(query)
    expect(disco.search('name:x')).to eq([123])
    expect(Chef::Config[:client_key]).to eq('baz.rb')
    expect(Chef::Config[:node_name]).to eq('bar')
  end
end
