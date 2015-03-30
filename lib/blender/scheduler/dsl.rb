#
# Author:: Ranjib Dey (<ranjib@pagerduty.com>)
# Copyright:: Copyright (c) 2014 PagerDuty, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'blender/exceptions'
require 'blender/scheduling_strategies/default'
require 'blender/tasks/base'
require 'blender/tasks/ruby'
require 'blender/tasks/ssh'
require 'blender/tasks/shell_out'
require 'blender/tasks/scp'
require 'blender/tasks/blend'
require 'highline'
require 'blender/utils/refinements'
require 'blender/drivers/ssh'
require 'blender/drivers/ssh'
require 'blender/drivers/ssh_multi'
require 'blender/drivers/shellout'
require 'blender/drivers/ruby'
require 'blender/drivers/scp'
require 'blender/drivers/blend'
require 'blender/discovery'
require 'blender/handlers/base'
require 'blender/lock/flock'

module Blender
  module SchedulerDSL
    include Blender::Utils::Refinements
    include Blender::Discovery

    def config(type, opts = {})
      update_config(type, opts)
    end

    alias :init :config

    def log_level(level)
      Blender::Log.level = level
    end

    def ask(msg, echo = false)
      HighLine.new.ask(msg){|q| q.echo = echo}
    end

    def driver(type, opts = {})
      klass_name = camelcase(type.to_s).to_sym
      config = symbolize(opts.merge(events: events))
      yield config if block_given?
      begin
        Blender::Driver.const_get(klass_name).new(config)
      rescue NameError => e
        raise UnknownDriver, e.message
      end
    end

    def add_handler(handler)
      events.register(handler)
    end

    alias :register_handler :add_handler

    def on(event_type, &block)
      add_handler(
        Class.new(Handlers::Base) do
          define_method(event_type) do |*args|
            block.call(args)
          end
        end.new
      )
    end

    def build_task(name, type)
      task_klass = Blender::Task.const_get(camelcase(type.to_s).to_sym)
      task = task_klass.new(name)
      task.members(metadata[:members]) unless metadata[:members].empty?
      task
    end

    def append_task(type, task, driver_config = {})
      Log.debug("Appended task:#{task.name}")
      klass = Blender::Driver.const_get(camelcase(type.to_s).to_sym)
      if task.driver.nil?
        opts = driver_config.dup
        opts.merge!(blender_config(type)) unless blender_config(type).empty?
        opts.merge!(task.driver_opts)
        task.use_driver(driver(type, opts))
      end
      @tasks << task
    end

    def shell_task(name, &block)
      task = build_task(name, :shell_out)
      task.members(['localhost'])
      task.instance_eval(&block) if block_given?
      append_task(:shell_out, task)
    end

    def ruby_task(name, &block)
      task = build_task(name, :ruby)
      task.instance_eval(&block) if block_given?
      append_task(:ruby, task)
    end

    def ssh_task(name, &block)
      task = build_task(name, :ssh)
      task.instance_eval(&block) if block_given?
      if task.metadata[:concurrency] == 1
        append_task(:ssh, task)
      else
        append_task(:ssh_multi, task, blender_config(:ssh))
      end
    end

    def scp_upload(name, &block)
      task = build_task(name, :scp)
      task.instance_eval(&block) if block_given?
      task.direction = :upload
      append_task(:scp, task, blender_config(:ssh))
    end

    def scp_download(name, &block)
      task = build_task(name, :scp)
      task.instance_eval(&block) if block_given?
      task.direction = :download
      append_task(:scp, task, blender_config(:ssh))
    end

    def blend_task(name, &block)
      task = build_task(name, :blend)
      task.instance_eval(&block) if block_given?
      task.command.pass_configs.each do |key|
        task.command.config_store[key] = blender_config(key).dup
      end
      append_task(:blend, task)
    end

    def strategy(strategy)
      klass_name = camelcase(strategy.to_s).to_sym
      begin
        @scheduling_strategy = Blender::SchedulingStrategy.const_get(klass_name).new
        @scheduling_strategy.freeze
      rescue NameError => e
        raise UnknownSchedulingStrategy, e.message
      end
    end

    def concurrency(value)
      @metadata[:concurrency] = value
    end

    def ignore_failure(value)
      @metadata[:ignore_failure] = value
    end

    def members(hosts)
      @metadata[:members] = hosts
    end

    def lock_options(driver, opts = {})
      @lock_properties[:driver] = driver
      @lock_properties[:driver_options].merge!(opts.dup)
    end

    def lock(opts = {})
      options = lock_properties.dup.merge(opts)
      if options[:driver]
        lock_klass = Lock.const_get(camelcase(options[:driver]).to_sym)
        lock_klass.new(name, options[:driver_options]).with_lock do
          yield if block_given?
        end
      else
        yield if block_given?
      end
    end

    alias_method :task, :shell_task
  end
end
