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

require 'blender/utils/ui'
require 'blender/configuration'

module Blender
  module Handlers
    class Doc < Base
      attr_reader :ui

      def initialize
        @ui = Blender::Utils::UI.new
      end

      def run_started(scheduler)
        @start_time = Time.now
        @task_id = 0
        @job_id = 1
        ui.puts_green("Run[#{scheduler.name}] started")
        ui.puts_green('Running in No-Op mode, driver execution will be skipped') if Configuration[:noop]
      end

      def run_finished(scheduler)
        delta = ( Time.now - @start_time)
        ui.puts_green("Run finished (#{delta} s)")
      end

      def run_failed(scheduler, e)
        delta = ( Time.now - @start_time)
        ui.puts_red("Run failed (#{delta} s)")
        ui.puts_red("Error :#{e.class} Message: #{e.message}")
        ui.puts_red("Backtrace :#{e.backtrace.join("\n")}")
      end

      def job_started(job)
        ui.puts("  #{job.to_s} started")
      end

      def job_finished(job)
      end

      def job_failed(job, e)
        ui.puts_red("  #{job.to_s} failed")
      end

      def job_computation_started(strategy)
        @compute_start_time = Time.now
        @strategy = strategy.class.name.split('::').last
      end

      def job_computation_finished(scheduler, jobs)
        delta = Time.now - @compute_start_time
        ui.puts(" #{jobs.size} job(s) computed using '#{@strategy}' strategy")
      end
    end
  end
end
