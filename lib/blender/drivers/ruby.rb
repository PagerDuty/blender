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

      def execute(tasks, hosts)
        tasks.each do |task|
          hosts.each do |host|
            events.command_started(task.command)
            cmd = run_command(task.command, host)
            events.command_finished(task.command, cmd)
            if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
              raise Exceptions::ExecutionFailed, cmd.stderr
            end
          end
        end
      end

      def run_command(command, host)
        exit_status = 0
        err = ''
        current_stdout = STDOUT.clone
        current_stderr = STDERR.clone
        begin
          STDOUT.reopen(stdout)
          STDERR.reopen(stderr)
          command.call(host)
        rescue StandardError => e
          err = e.message
          exit_status = -1
        ensure
          STDOUT.reopen(current_stdout)
          STDERR.reopen(current_stderr)
        end
        ExecOutput.new(exit_status, '', err)
      end
    end
  end
end
