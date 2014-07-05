require 'blender/exceptions'
require 'blender/scheduling_strategy'
require 'blender/tasks/base'
require 'highline'

module Blender
  module SchedulerDSL

    def ask(msg)
      HighLine.new.ask(msg){|q| q.echo = false}
    end

    def register_handler(handler)
      @events.register(handler)
    end

    def task(command)
      task = Blender::Task::Base.new(command)
      yield task if block_given?
      Log.debug("Appended task:#{task.inspect}")
      @tasks << task
    end

    def strategy(strategy)
      @strategy = SchedulingStrategy.get(strategy)
    end

    def concurrency(value)
      @metadata[:concurrency] = value
    end

    def ignore_failure(value)
      @metadata[:ignore_failure] = value
    end

    def members(members)
      Log.debug("Setting members:#{members.inspect}")
      @metadata[:members] = members
    end

    def driver(type)
      config = {events: @events}
      yield config if block_given?
      @default_driver = Driver.get(type).new(config)
    end

    def register_driver(type, name, config = nil)
      @registered_drivers[name] = Driver.get(type).new(config.merge(events: @events))
    end
  end
end
