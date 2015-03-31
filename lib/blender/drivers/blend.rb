#
# Author:: Ranjib Dey (<ranjib@pagerduty.com>)
# Copyright:: Copyright (c) 2015 PagerDuty, Inc.
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
    class Blend < Base
      def execute(tasks, hosts)
        tasks.each do |task|
          cmd = run_command(task.command, hosts)
          if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
            raise ExecutionFailed, cmd.stderr
          end
        end
      end

      def run_command(command, hosts)
        exit_status = 0
        err = ''
        begin
          Blender.blend(command.file, command.options) do |sched|
            sched.strategy(command.strategy)
            sched.members(hosts)
            sched.concurrency(command.concurrency)
            command.config_store.keys.each do |key|
              sched.config(key, command.config_store[key])
            end
            sched.instance_eval(File.read(command.file))
          end
        rescue StandardError => e
          err = e.message + "\nBacktrace:" + e.backtrace.join("\n")
          exit_status = -1
        end
        ExecOutput.new(exit_status, '', err)
      end
    end
  end
end
