require 'blender/exceptions'
require 'blender/scheduling_strategy'
require 'blender/tasks/base'
require 'blender/tasks/ruby'
require 'blender/tasks/ssh'
require 'blender/tasks/serf'
require 'blender/driver'
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
      task.use_driver(Driver.get(:local).new(events: @events))
      yield task if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task)
      @tasks << task
    end

    def ruby_task(name)
      task = Blender::Task::RubyTask.new(name)
      task.use_driver(Driver.get(:ruby).new(events: @events))
      yield task if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, Blender::Driver::Ruby)
      @tasks << task
    end

    def ssh_task(name)
      task = Blender::Task::SSHTask.new(name)
      task.use_driver(Driver.get(:ssh).new(events: @events))
      yield task if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, Blender::Driver::Ssh)
      @tasks << task
    end

    def serf_task(name)
      task = Blender::Task::SerfTask.new(name)
      task.use_driver(Driver.get(:serf).new(events: @events))
      yield task if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, Blender::Driver::Serf)
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

    private
    def validate_driver!(t, klass = nil)
      case t.driver
      when String
        unless @registered_drivers.key?(t.driver)
          raise "Unknown driver #{t.driver} for task #{t.name}"
        else
          t.use_driver(@registered_drivers[t.driver])
        end
      when Blender::Driver::Base
        if klass
          unless t.driver.is_a?(klass)
            raise "Incompatible driver for task #{t.name} expected:#{klass} got:#{t.driver.class}"
          end
        end
      else
        raise "Unknown driver #{t.driver} for task #{t.name}"
      end
    end
  end
end
