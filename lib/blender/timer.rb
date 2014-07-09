require 'rufus-scheduler'
require 'blender/scheduled_job'

module Blender
  class Timer
    def initialize
      @scheduled_jobs = []
    end

    def schedule(name, &block)
      job = Blender::ScheduledJob.new(name)
      job.instance_eval(&block)
      @scheduled_jobs << job
    end

    def join
      scheduler = Rufus::Scheduler.new
      @scheduled_jobs.each do |job|
        case job.schedule.first
        when :every
          scheduler.every(*job.schedule[1]) do
            job.run
          end
        when :cron
          scheduler.cron(job.schedule[1]) do
            job.run
          end
        else
          raise "Unsupported scheduling: '#{job.schedule.first}'"
        end
      end
      scheduler.join
    end
  end
end
