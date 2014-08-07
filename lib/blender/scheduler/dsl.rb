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
require 'highline'
require 'blender/utils/refinements'
require 'blender/drivers/ssh'
require 'blender/drivers/ssh_multi'
require 'blender/drivers/shellout'
require 'blender/drivers/ruby'
require 'blender/discovery'

module Blender
  module SchedulerDSL
    include Blender::Utils::Refinements
    include Blender::Discovery

    def init(type, opts = {})
      init_config[type].merge!(opts)
    end

    def log_level(level)
      Blender::Log.level = level
    end

    def ask(msg, echo = false)
      HighLine.new.ask(msg){|q| q.echo = echo}
    end

    def driver(type, opts = {})
      klass_name = camelcase(type.to_s).to_sym
      config = opts.merge(events: @events)
      yield config if block_given?
      begin
        Blender::Driver.const_get(klass_name).new(config)
      rescue NameError => e
        raise Exceptions::UnknownDriver, e.message
      end
    end

    def register_handler(handler)
      @events.register(handler)
    end

    def build_task(name, type)
      task_klass = Blender::Task.const_get(camelcase(type.to_s).to_sym)
      driver_klass = Blender::Driver.const_get(camelcase(type.to_s).to_sym)
      task = task_klass.new(name, init_config: init_config[type])
      task.members(metadata[:members]) unless metadata[:members].empty?
      task
    end

    def append_task(type, task)
      Log.debug("Appended task:#{task.name}")
      klass = Blender::Driver.const_get(camelcase(type.to_s).to_sym)
      if task.driver.nil?
        opts = {}
        opts.merge!(init_config[type]) if init_config[type]
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
      append_task(:ssh, task)
    end

    def strategy(strategy)
      klass_name = camelcase(strategy.to_s).to_sym
      begin
        @scheduling_strategy = Blender::SchedulingStrategy.const_get(klass_name).new
        @scheduling_strategy.freeze
      rescue NameError => e
        raise Exceptions::UnknownSchedulingStrategy, e.message
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

    alias_method :task, :shell_task
  end
end
