require 'blender/drivers/base'

module Blender
  module Driver
    class Ruby < Local
      def raw_exec(command)
        exit_status = 0
        stderr = ''
        begin
          command.call
        rescue Exception => e
          stderr = e.message
          exit_status = -1
        end
        ExecOutput.new(exit_status, '', stderr)
      end
    end
  end
end
