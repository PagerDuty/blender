require 'spec_helper'

describe Blender do
  it 'allows sub-blend' do
    expect(File).to receive(:read).with('/tmp/fake.rb').and_return('')
    sched = Blender.blend('sub blend', no_doc: true) do |sched|
      sched.config(:scp, user: 'test-user', password: 'test-password')
      sched.members(['1.2.3.4'])
      sched.blend_task 'foo' do
        file '/tmp/fake.rb'
        strategy :per_task
        pass_configs :scp
        concurrency 3
      end
    end
  end
end
