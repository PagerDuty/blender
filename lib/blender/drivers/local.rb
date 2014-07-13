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

require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/base'

module Blender
  module Driver
    class Local < Base
      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        verify_local_host!(hosts)
        Array(tasks).each do |task|
          converge_by "will be executing: #{task.command.inspect}" do
            cmd = raw_exec(task.command)
            if cmd.exitstatus != 0
              raise Exceptions::ExecutionFailed, cmd.stderr
            end
          end
        end
      end

      def verify_local_host!(hosts)
        unless Array(hosts).all?{|h|h == 'localhost'}
          raise Exceptions::UnsupportedFeature, 'ShellOut driver does not support any host other than localhost'
        end
      end
    end
  end
end
