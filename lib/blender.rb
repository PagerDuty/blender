require 'blender/version'
require 'blender/scheduler'
require 'blender/task'
require 'blender/log'
require 'blender/drivers/shellout'

module Blender
  def self.blend(name)
    if block_given?
      Log.debug('Advance blending in progress...')
      scheduler = Scheduler.new(name)
      yield scheduler
    else
      Log.debug('Newbie blending in progress...')
      scheduler = Scheduler.new(name)
      scheduler.task(name)
    end
    scheduler.run
  end

  def self.async_blending(name)
    Log.debug('Blending in background!')
    pid = fork do
      blend(name)
    end
    Process.detach(pid)
    Log.debug("Blender PID:#{pid}")
    pid
  end
end
