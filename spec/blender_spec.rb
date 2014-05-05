require 'spec_helper'
require 'mixlib/shellout'

describe Blender do

  examples = File.expand_path('../../examples', __FILE__)
  repo_home = File.expand_path('../../', __FILE__)

  Dir["#{examples}/*.rb"].each do |example|

    name = File.basename(example)
    it "should succecssfully run example[#{name}]" do
      command = "bundle exec ruby #{example}"
      cmd = Mixlib::ShellOut.new(command, cwd: repo_home)
      cmd.run_command
      expect(cmd.exitstatus).to eq(0)
    end
  end
end
