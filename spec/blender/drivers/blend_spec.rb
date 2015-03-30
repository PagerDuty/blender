require 'spec_helper'

describe Blender do
  let(:scp_config) do
    { user: 'test-user', password: 'test-password' }
  end
  let!(:sched) do
    blender_file = File.expand_path('../../../data/example.rb', __FILE__)
    sched = Blender.blend('sub blend', no_doc: true) do |sched|
      sched.config(:scp, scp_config)
      sched.members(['1.2.3.4'])
      sched.blend_task 'foo' do
        file blender_file
        strategy :per_task
        pass_configs :scp
        concurrency 3
      end
    end
  end

  it 'passes apropriate config options from parent blender script' do
    blend_task = sched.tasks.first
    expect(blend_task.command.config_store[:scp]).to eq(scp_config)
  end
end
