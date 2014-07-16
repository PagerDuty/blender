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

require 'blender/drivers/base'

module Blender
  module Driver
    class Ruby < Base

      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        Array(tasks).each do |task|
          Array(hosts).each do |host|
            converge_by "will be executing: #{task.command.inspect}" do
              cmd = raw_exec(task.command, host)
              if cmd.exitstatus != 0
                raise Exceptions::ExecutionFailed, cmd.stderr
              end
            end
          end
        end
      end
      def raw_exec(command, host)
        exit_status = 0
        stderr = ''
        begin
          command.call(host)
        rescue Exception => e
          stderr = e.message
          exit_status = -1
        end
        ExecOutput.new(exit_status, '', stderr)
      end
    end
  end
end
