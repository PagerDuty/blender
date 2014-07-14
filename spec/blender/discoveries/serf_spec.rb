require 'spec_helper'

describe Blender::Discovery::SerfDiscovery do
  let(:discovery){described_class.new(host: '1.2.3.4')}
  it '#search' do
    conn = double('connection')
    response = double('response', body: {'Members'=> [{'Name'=>'a'}]})
    expect(conn).to receive(:members_filtered).with({}, "alive", "foo").and_return(response)
    expect(Serfx).to receive(:connect).with(host: '1.2.3.4').and_yield(conn)
    expect(discovery.search(name: 'foo')).to eq(['a'])
  end
end
