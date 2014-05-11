module Blender
  module Task
    class Base
      attr_reader :guards, :metadata, :name

      def initialize(name, metadata = {})
        @name = name
        @metadata = default_metadata.merge(metadata)
        @guards = {not_if: [], only_if: []}
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

      def default_metadata
        {
        timout: 60,
        ignore_failure: false,
        async: 0,
        handlers: []
        }
      end
    end
  end
end
