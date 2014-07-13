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

require 'rufus-scheduler'
require 'blender/scheduled_job'

module Blender
  # Timer class provides a simple dsl for running blender jobs periodically.
  # It uses Rufus::Scheduler for scheduling jobs
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
          scheduler.every(job.schedule[1]) do
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
