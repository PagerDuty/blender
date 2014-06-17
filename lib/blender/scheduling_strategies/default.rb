require 'blender/log'
require 'blender/job'

module Blender
  module SchedulingStrategy
    class Default
      def compute_jobs(tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        pairs = tasks.product(members)
        job_id = 0
        jobs = pairs.map do |task, host|
          Log.debug("Creating job (#{host}|#{task.name})")
          job_id += 1
          Job.new(job_id, "#{host}(#{task.name})", host, task)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
    class PerTask
      def compute_jobs(tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        job_id = 0
        jobs = tasks.map do |task|
          Log.debug("Creating job (#{members.size}|#{task.name})")
          job_id += 1
          Job.new(job_id, "#{members.size}(#{task.name})", members, task)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
    class PerHost
      def compute_jobs(tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        pairs = members.product(tasks)
        job_id = 1
        jobs = members.map do |host|
          job_id += 1
          Job.new(job_id, "#{host}(#{tasks.map(&:name).join(',')})", host, tasks)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
  end
end
