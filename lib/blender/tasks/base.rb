module Blender
  module Task
    class Base
      attr_reader :guards, :metadata, :name, :hosts, :driver

      def initialize(name, metadata = {})
        @name = name
        @metadata = default_metadata.merge(metadata)
        @guards = {not_if: [], only_if: []}
        @hosts = nil
        @driver = nil
        @before_hooks = []
        @after_hooks = []
      end

      def use_driver(driver)
        @driver = driver
      end

      def before(&block)
        @before_hooks << block
      end

      def after(&block)
        @after_hooks << block
      end

      def ignore_failure(value)
        @metadata[:ignore_failure] = value
      end

      def not_if(cmd)
        @guards[:not_if] << cmd
      end

      def only_if(cmd)
        @guards[:only_if] << cmd
      end

      def execute(cmd)
        @command = cmd
      end

      def command
        @command || name
      end

      def members(hosts)
        @hosts = hosts
      end

      def default_metadata
        {
        timout: 60,
        ignore_failure: false,
        retries: 0,
        retry_delay: 0,
        async: 0,
        handlers: []
        }
      end
    end
  end
end
