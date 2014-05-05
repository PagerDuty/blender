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
            @queue.pop.call while true
          end
        end
        until @queue.empty? and (@queue.num_waiting == num)
          threads.each do |thread|
            thread.join(0.02)
          end
        end
        threads.map(&:kill)
      end
    end
  end
end
