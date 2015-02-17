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
  it '#download' do
    session = double('Net::SSH::Session', loop: true)
    scp = double('Net::SSH::Scp')
    expect(Net::SSH).to receive(:start).with('host1', 'x', password: 'y').and_return(session)
    expect(session).to receive(:scp).and_return(scp)
    expect(scp).to receive(:download!).with('/remote/path', '/local/path', {})
    Blender.blend('test') do |sched|
      sched.members(['host1'])
      sched.config(:scp, user: 'x', password: 'y')
      sched.scp_download '/remote/path' do
        to '/local/path'
      end
    end
  end
end
