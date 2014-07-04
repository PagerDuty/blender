require 'rufus-scheduler'

module Blender
  class Timer < Rufus::Scheduler
    def ruby_blend(name, &block)
      puts name
      sleep 10
      block.call
    end
  end
end
