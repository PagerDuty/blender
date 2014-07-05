require 'blender/log'
require 'blender/job'

module Blender
  module SchedulingStrategy
    class Base
      def detect_driver
        task_drivers =  Array(tasks).collect(&:driver).compact.uniq
        if task_drivers.size == 1
          @driver = task_drivers.first
        elsif task_drivers.empty?
          @driver = default_driver
        else
          raise 'Job container tasks with heretogenous drivers'
        end
      end
    end
    class Default < Base
      def compute_jobs(driver, tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        pairs = tasks.map{|t| [t].product(t.hosts || members)}.flatten(1)
        job_id = 0
        jobs = pairs.map do |task, host|
          Log.debug("Creating job (#{host}|#{task.name})")
          job_id += 1
          Job.new(job_id, driver,  host, task)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
    class PerTask < Base
      def compute_jobs(driver, tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        job_id = 0
        jobs = tasks.map do |task|
          hosts = task.hosts || members
          Log.debug("Creating job (#{hosts.size}|#{task.name})")
          job_id += 1
          Job.new(job_id, driver, hosts, task)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
    class PerHost < Base
      def compute_jobs(driver, tasks, members)
        Log.debug("Computing jobs from #{tasks.size} tasks and #{members.size} members")
        if tasks.any?{|t| not t.hosts.nil?}
          raise 'PerHost strategy does not support scheduling tasks with memebers'
        end
        pairs = members.product(tasks)
        job_id = 1
        jobs = members.map do |host|
          job_id += 1
          Job.new(job_id, driver, host, tasks)
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
  end
end
