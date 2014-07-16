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
require 'blender/tasks/serf'
require 'highline'
require 'blender/utils/refinements'
require 'blender/drivers/ssh'
require 'blender/drivers/ssh_multi'
require 'blender/drivers/shellout'
require 'blender/drivers/serf'
require 'blender/drivers/serf_multi'
require 'blender/drivers/serf_async'
require 'blender/drivers/ruby'
require 'blender/discoveries/chef'
require 'blender/discoveries/serf'

module Blender
  module SchedulerDSL
    include Blender::Utils::Refinements

    def log_level(level)
      Blender::Log.level = level
    end

    def ask(msg, echo = false)
      HighLine.new.ask(msg){|q| q.echo = echo}
    end

    def register_handler(handler)
      @events.register(handler)
    end

    def build_task(name, type)
      task_klass = Blender::Task.const_get(camelcase(type.to_s).to_sym)
      driver_klass = Blender::Driver.const_get(camelcase(type.to_s).to_sym)
      task = task_klass.new(name)
      if @default_driver.is_a?(driver_klass)
        task.use_driver(@default_driver)
      else
        task.use_driver(driver(type, events: @events))
      end
      task
    end

    def build_discovery(type, opts = {})
      disco_klass = Blender::Discovery.const_get(camelcase(type.to_s).to_sym)
      disco_klass.new(opts)
    end

    def task(name, &block)
      task = build_task(name, :shell_out)
      task.instance_eval(&block) if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, :shell_out)
      @tasks << task
    end

    def ruby_task(name, &block)
      task = build_task(name, :ruby)
      task.instance_eval(&block) if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, :ruby)
      @tasks << task
    end

    def ssh_task(name, &block)
      task = build_task(name, :ssh)
      task.instance_eval(&block) if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, :ssh)
      @tasks << task
    end

    def serf_task(name, &block)
      task = build_task(name, :serf)
      task.instance_eval(&block) if block_given?
      Log.debug("Appended task:#{task.inspect}")
      validate_driver!(task, :serf)
      @tasks << task
    end

    def strategy(strategy)
      klass_name = camelcase(strategy.to_s).to_sym
      begin
        @strategy = Blender::SchedulingStrategy.const_get(klass_name).new
        @strategy.freeze
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

    def members(members)
      Log.debug("Setting members:#{members.inspect}")
      @metadata[:members] = members
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

    def global_driver(type, opts = {})
      @default_driver = driver(type, opts)
      @default_driver.freeze
    end

    def register_driver(type, name, config = nil)
      @registered_drivers[name] = driver(type, config.merge(events: @events).dup)
    end

    def register_discovery(type, name, opts = {})
      @registered_discoveries[name] = build_discovery(type)
    end

    def discover_by(name, opts ={})
      @registered_discoveries[name].search(opts)
    end

    def serf_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:serf, options).search(search_opts)
    end

    def chef_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:chef, options).search(search_opts)
    end

    private
    def validate_driver!(t, type)
      klass = Blender::Driver.const_get(camelcase(type.to_s).to_sym)
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
