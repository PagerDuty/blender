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

require 'blender/drivers/compound'

module Blender
  module SchedulingStrategy
    class PerHost < Base
      def compute_jobs(tasks)
        Log.debug("Computing jobs from #{tasks.size} tasks")
        hosts_list = tasks.map(&:hosts).uniq
        if hosts_list.size != 1
          raise UnsupportedFeature, 'PerHost strategy does not support scheduling tasks with different memebers'
        end
        job_id = 0
        jobs = hosts_list.first.map do |host|
          job_id = job_id + 1
          Job.new(job_id, Blender::Driver::Compound.new, tasks, [host])
        end
        Log.debug("Total jobs : #{jobs.size}")
        jobs
      end
    end
  end
end
