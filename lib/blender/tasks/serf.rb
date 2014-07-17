require 'blender/tasks/base'

module Blender
  module Task
    class Serf < Blender::Task::Base


      SerfQuery = Struct.new(:query, :payload, :timeout, :noack, :process)

      def initialize(name, metadata = {})
        super
        @command = SerfQuery.new
        @command.query = name
      end

      def execute(&block)
        @command.instance_eval(&block)
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

      def process(callback)
        @command.process = callback
      end

      def command
        @command
      end
    end
  end
end
