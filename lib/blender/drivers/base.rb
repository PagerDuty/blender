require 'blender/log'

module Blender
  module Driver
    class Base

      ExecOutput = Struct.new(:exitstatus, :stdout, :stderr)

      def initialize(config)
        @events = config.delete(:events) or fail 'Events needed'
        @config = default_config.merge(config)
      end

      def converge_by(desc)
        if config[:why_run]
          @events.skipping_for_why_run(desc)
        else
          yield
        end
      end

      def evaluate_guards?(task)
        if task.guards[:not_if].empty? and task.guards[:only_if].empty?
          false
        else
          task.guards[:not_if].all? do |command|
            raw_exec(command).exitstatus == 0
          end and
          task.guards[:only_if].all? do |command|
            raw_exec(command).exitstatus != 0
          end
        end
      end

      # returns 0 upon success
      def raw_exec(command)
        raise RuntimeError, 'this method must be overridden'
      end

      def execute(tasks, hosts)
        raise RuntimeError, 'this method must be overridden'
      end

      private
      def default_config
        {
          timout: 60, 
          ignore_failure: false,
          why_run: false,
          stdout: $stdout,
          stderr: $stderr
        }
      end

      def config
        @config
      end
    end
  end
end
