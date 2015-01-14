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

require 'mixlib/shellout'

module Blender
  module Driver
    class ShellOut < Base

      def initialize(config = {})
        @options = {}
        cfg = config.dup
        [:user, :group, :cwd, :umask, :returns, :environment, :timeout].each do |key|
          @options[key] = cfg.delete(key) if cfg.key?(key)
        end
        super(cfg)
      end

      def execute(tasks, hosts)
        verify_local_host!(hosts)
        tasks.each do |task|
          cmd = run_command(task.command)
          if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
            raise ExecutionFailed, cmd.stderr
          end
        end
      end

      def run_command(command)
        cmd = Mixlib::ShellOut.new(command, @options)
        begin
          cmd.live_stream = stdout
          cmd.run_command
          ExecOutput.new(cmd.exitstatus, cmd.stdout, cmd.stderr)
        rescue Errno::ENOENT => e
          ExecOutput.new(-1, '', e.message)
        end
      end

      def verify_local_host!(hosts)
        unless hosts.all?{|h|h == 'localhost'}
          raise UnsupportedFeature, 'This driver does not support any host other than localhost'
        end
      end
    end
  end
end
