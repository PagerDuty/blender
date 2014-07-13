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
