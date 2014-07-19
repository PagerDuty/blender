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

module Blender
  module Handlers
    class Base
      def run_started(scheduler)
      end
      def run_finished(scheduler)
      end
      def job_computation_started(strategy)
      end
      def job_computation_finished(strategy, jobs)
      end
      def command_started(command)
      end
      def command_finished(command, status)
      end
      def command_errored(command)
      end
      def job_started(job)
      end
      def job_finished(job)
      end
      def job_errored(job, error)
      end
      def skipping_for_why_run(desc)
      end
    end
  end
end
