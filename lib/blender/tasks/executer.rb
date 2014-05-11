require 'blender/drivers/shellout'
require 'blender/drivers/ssh'
require 'blender/log'
require 'blender/tasks/base'

module Blender
  module Task
    class Executer < Blender::Task::Base

      def execute(cmd)
        @command = cmd
      end

      def command
        @command || name
      end
    end
  end
end
