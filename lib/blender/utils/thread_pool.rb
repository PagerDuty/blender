require 'thread'
require 'blender/log'

module Blender
  module Utils
    class ThreadPool

      def initialize(size)
        @size = size
        @queue = Queue.new
      end

      def add_job(&blk)
        @queue << blk
      end

      def run_till_done
        num = @size > @queue.size ? @queue.size : @size
        threads = Array.new(num) do
          Thread.new do
            Thread.current.abort_on_exception = true
            @queue.pop.call while true
          end
        end
        until @queue.empty?
          sleep 0.2
        end
        threads.each do |thread|
          thread.join(0.02)
        end
        threads.map(&:kill)
      end
    end
  end
end
