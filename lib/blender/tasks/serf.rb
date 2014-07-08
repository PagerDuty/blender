require 'blender/tasks/base'

module Blender
  module Task
    class SerfTask < Blender::Task::Base

      SerfQuery = Struct.new(:query, :payload, :timeout, :noack)

      def initialize(name, metadata = {})
        super
        @command = SerfQuery.new
      end

      def query(q)
        @command.query = q
      end

      def timeout(t)
        @command.timeout = t
      end

      def payload(pl)
        @command.payload = pl
      end

      def no_ack(bool)
        @command.noack = bool
      end

      def command
        @command
      end
    end
  end
end
