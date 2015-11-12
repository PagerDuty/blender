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

require 'net/ssh'
require 'blender/exceptions'
require 'blender/drivers/base'
require 'blender/drivers/ssh_exec'

module Blender
  module Driver
    class Ssh < Base
      attr_reader :user
      include SSHExec

      def initialize(config = {})
        cfg = config.dup
        @user = cfg.delete(:user) || ENV['USER']
        super(cfg)
      end

      def execute(tasks, hosts)
        Log.debug("SSH execution tasks [#{Array(tasks).size}]")
        Log.debug("SSH on hosts [#{hosts.join(",")}]")
        Array(hosts).each do |host|
          session = create_session(host)
          Array(tasks).each do |task|
            cmd = run_command(task.command, session)
            if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
              raise ExecutionFailed, cmd.stderr
            end
          end
          session.loop
        end
      end

      def run_command(command, session)
        exit_status = remote_exec(command, session)
        stdout.rewind
        stderr.rewind
        ExecOutput.new(exit_status, stdout.read, stderr.read)
      end

      private

      def create_session(host)
        Log.debug("Invoking ssh: #{user}@#{host}")
        Net::SSH.start(host, user, config)
      end
    end
  end
end
