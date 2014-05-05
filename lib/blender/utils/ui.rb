require 'highline'

module Blender
  module Utils
    class UI
      def initialize
        @mutex = Mutex.new
        @highline = HighLine.new
      end
      def puts(string)
        @mutex.synchronize do
          $stdout.puts(string)
        end
      end

      def puts_red(string)
        puts(color(string, :red))
      end

      def puts_cyan(string)
        puts(color(string, :cyan))
      end

      def puts_green(string)
        puts(color(string, :green))
      end

      def color(string, *colors)
        @highline.color(string, *colors)
      end
      
    end
  end
end
