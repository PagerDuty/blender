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
        cfg[:stdout] ||= {}
        cfg[:stderr] ||= {}
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
              raise ExecutionFailed, { stderr: cmd.stderr, stdout: cmd.stdout }.to_json
            end
          end
          session.loop
        end
      end

      def run_command(command, session)
        aggregate_results(remote_exec(command, session))
      end

      private

      def create_session(host)
        Log.debug("Invoking ssh: #{user}@#{host}")
        Net::SSH.start(host, user, config)
      end

      def aggregate_results(command_results)
        status = command_results.all? { |k,v| v.exitstatus.zero? } ? 0 : 1
        @stdout.merge!(join_output(command_results, :stdout))
        @stderr.merge!(join_output(command_results, :stderr))
        ExecOutput.new(status, stdout, stderr)
      end

      def join_output(results, stream_name)
        output = {}
        results.each { |host, result| output[host] = result.send(stream_name).read }
        output
      end
    end
  end
end
