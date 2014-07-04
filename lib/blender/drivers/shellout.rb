require 'mixlib/shellout'
require 'blender/drivers/local'

module Blender
  module Driver
    class ShellOut < Local
      def raw_exec(command)
        cmd = Mixlib::ShellOut.new(command)
        cmd.live_stream = config[:stdout]
        cmd.run_command
        ExecOutput.new(cmd.exitstatus, cmd.stdout, cmd.stderr)
      end
    end
  end
end
