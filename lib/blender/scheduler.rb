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

require 'blender/log'
require 'blender/utils/thread_pool'
require 'blender/exceptions'
require 'blender/scheduling_strategies/default'
require 'blender/utils/thread_pool'
require 'blender/scheduler/dsl'
require 'blender/event_dispatcher'
require 'blender/handlers/doc'
require 'blender/tasks/base'

module Blender
  class Scheduler

    include SchedulerDSL

    attr_reader :metadata, :name, :registered_discoveries, :scheduling_strategy
    attr_reader :events, :tasks, :default_driver, :registered_drivers

    def initialize(name, tasks = [], metadata = {})
      @name = name
      @tasks = tasks
      @metadata = default_metadata.merge(metadata)
      @events = Blender::EventDispatcher.new
      events.register(Blender::Handlers::Doc.new)
      @registered_discoveries = {}
      @registered_drivers = {}
      @default_driver = nil
      @scheduling_strategy = nil
    end

    def run
      @scheduling_strategy ||= SchedulingStrategy::Default.new
      events.run_started(self)
      @default_driver ||= driver(:shell_out, events: events)
      events.job_computation_started()
      jobs = scheduling_strategy.compute_jobs(@tasks)
      events.job_computation_finished(self, jobs)
      if metadata[:concurrency] > 1
        concurrent_run(jobs)
      else
        serial_run(jobs)
      end
      events.run_finished(self)
      jobs
    end

    def serial_run(jobs)
      Log.debug('Invoking serial run')
      jobs.each do |job|
        run_job(job)
      end
    end

    def concurrent_run(jobs)
      c = metadata[:concurrency]
      Log.debug("Invoking concurrent run with concurrency:#{c}")
      pool = Utils::ThreadPool.new(c)
      jobs.each do |job|
        pool.add_job do
          run_job(job)
        end
      end
      pool.run_till_done
    end

    def run_job(job)
      events.job_started(job)
      begin
        Log.debug("Running job #{job.inspect}")
        job.run
        events.job_finished(job)
      rescue Exception => e
        events.job_errored(job, e)
        if metadata[:ignore_failure]
          Log.warn("Exception: #{e.inspect} was suppressed, ignoring failure")
        else
          raise e
        end
      end
    end

    def default_metadata
      { timout: 60, ignore_failure: false, concurrency: 0,
       handlers: [], members: [] }
    end
  end
end
