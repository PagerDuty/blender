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
require 'blender/drivers/ssh'
require 'chef/monkey_patches/net-ssh-multi'

module Blender
  module Driver
    class SshMulti < Ssh

      def execute(tasks, hosts)
        Log.debug("SSH execution tasks [#{tasks.name}]")
        Log.debug("SSH on hosts [#{hosts.join("\n")}]")
        session = ssh_multi_session(hosts)
        Array(tasks).each do |task|
          cmd = run_command(task.command, session)
          if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
            raise Exceptions::ExecutionFailed, cmd.stderr
          end
        end
        session.loop
      end

      def run_command(command, session)
        password = @config[:password]
        command = fixup_sudo(command)
        exit_status = 0
        channel = session.open_channel do |ch|
          ch.request_pty
          ch.exec(command) do |ch, success|
            unless success
              Log.debug("Command not found:#{success.inspect}")
              exit_status = -1
            end
            ch.on_data do |c, data|
              stdout << data
              if data =~ /^blender sudo password: /
                c.send_data("#{password}\n")
              end
            end
            ch.on_extended_data do |c, type, data|
              stderr << data
            end
            ch.on_request "exit-status" do |ichannel, data|
              l = data.read_long
              exit_status = [exit_status, l].max
              Log.debug("exit_status:#{exit_status} , data:#{l}")
            end
          end
          Log.debug("Exit(#{exit_status}) Command: '#{command}'")
        end
        channel.wait
        ExecOutput.new(exit_status, stdout, stderr)
      end

      def concurrency
        @config[:concurrency]
      end

      private

      def ssh_multi_session(hosts)
        user = @config[:user] || ENV['USER']
        ssh_config = { password: @config[:password]}
        error_handler = lambda do |server|
          if config[:ignore_on_failure]
            $!.backtrace.each { |l| Blender::Log.debug(l) }
          else
            throw :go, :raise
          end
        end
        s = Net::SSH::Multi.start(
          concurrent_connections: concurrency,
          on_error: error_handler
        )
        hosts.each do |h|
          s.use(user + '@' + h)
        end
        s
      end

      def default_config
        super.merge(concurrency: 5)
      end
    end
  end
end
