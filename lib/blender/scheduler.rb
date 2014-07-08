require 'blender/log'
require 'blender/utils/thread_pool'
require 'blender/driver'
require 'blender/exceptions'
require 'blender/scheduling_strategies/default'
require 'blender/utils/thread_pool'
require 'blender/scheduler/dsl'
require 'blender/event_dispatcher'
require 'blender/handlers/doc'
require 'blender/tasks/base'
require 'blender/discovery'

module Blender
  class Scheduler

    include SchedulerDSL
    include Discovery

    attr_reader :metadata, :name

    def initialize(name, tasks = [], metadata = {})
      @name = name
      @tasks = tasks
      @metadata = default_metadata.merge(metadata)
      @events = Blender::EventDispatcher.new
      @events.register(Blender::Handlers::Doc.new)
      @registered_discoveries = {}
      @registered_drivers = {}
      @default_driver = nil
      @strategy = nil
    end

    def run
      @strategy ||= SchedulingStrategy::Default.new
      @events.run_started(self)
      @default_driver ||= Driver.get(:local).new(events: @events)
      @events.job_computation_started(@strategy)
      jobs = @strategy.compute_jobs(@default_driver, @tasks, @metadata[:members])
      @events.job_computation_finished(self, jobs)
      if metadata[:concurrency] > 1
        concurrent_run(jobs)
      else
        serial_run(jobs)
      end
      @events.run_finished(self)
      nil
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
      Log.debug("Running job #{job.inspect}")
      @events.job_started(job)
      begin
        driver = job.driver || @default_driver
        driver.execute(job)
      rescue Exceptions::ExecutionFailed => e
        @events.job_errored(job, e)
        if metadata[:ignore_failure]
          Log.warn("Exception: #{e.inspect} was suppressed, ignoring failure")
        else
          raise e
        end
      end
      @events.job_finished(job)
    end

    def default_metadata
      { timout: 60, ignore_failure: false, concurrency: 0,
       handlers: [], members: ['localhost'] }
    end
  end
end
