require 'blender/tasks/base'

module Blender
  module Task
    class RubyTask < Blender::Task::Base

      attr_reader :code_block

      def not_if(&block)
        @guards[:not_if] << block
      end

      def only_if(&block)
        @guards[:only_if] << block
      end

      def execute(&block)
        @command = block
      end
    end
  end
end
