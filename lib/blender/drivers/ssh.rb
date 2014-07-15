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

module Blender
  module Driver
    class Ssh < Base

      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        Log.debug("SSH execution tasks [#{tasks.inspect}]")
        Log.debug("SSH on hosts [#{hosts.inspect}]")
        Array(hosts).each do |host|
          session = ssh_session(host)
          Array(tasks).each do |task|
            if evaluate_guards?(task)
              Log.debug("Host:#{host}| Guards are valid")
            else
              Log.debug("Host:#{host}| Guards are invalid")
              run_task_command(task, session)
            end
          end
          session.loop
        end
      end

      def run_task_command(task, session)
         e_status = raw_exec(task.command, session).exitstatus
         if e_status != 0
           if task.metadata[:ignore_failure]
             Log.warn('Ignore failure is set, skipping failure')
           else
            raise Exceptions::ExecutionFailed, "Failed to execute '#{task.command}'"
           end
         end
      end

      def raw_exec(command, session)
        password = @config[:password]
        command = fixup_sudo(command)
        exit_status = 0
        stdout = config[:stdout] || File.open(File::NULL, 'w')
        stderr = config[:stderr] || File.open(File::NULL, 'w')
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

      private

      def ssh_session(host)
        user = @config[:user] || ENV['USER']
        ssh_config = { password: @config[:password]}
        Log.debug("Invoking ssh: #{user}@#{host}")
        Net::SSH.start(host, user, ssh_config)
      end

      def fixup_sudo(command)
        command.sub(/^sudo/, 'sudo -p \'blender sudo password: \'')
      end
    end
  end
end
