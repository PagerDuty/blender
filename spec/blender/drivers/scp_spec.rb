require 'spec_helper'

describe Blender do
  it 'passes scp options' do
    scp = double('Net::SCP')
    session = double('Net::SSH::Session', scp: scp, loop: true)
    expect(Net::SSH).to receive(:start).with('1.2.3.4', 'test-user', password: 'test-password').and_return(session)
    expect(scp).to receive(:upload!).with('/tmp/from', '/tmp/to', recursive: true)
    sched = Blender.blend('scp', no_doc: true) do |sched|
      sched.config(:scp, user: 'test-user', password: 'test-password')
      sched.members(['1.2.3.4'])
      sched.scp_upload 'foo' do
        recursive true
        from '/tmp/from'
        to '/tmp/to'
      end
    end
  end
end
