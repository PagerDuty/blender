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
      attr_reader :user

      def initialize(config = {})
        cfg = config.dup
        @user = cfg.delete(:user) || ENV['USER']
        super(cfg)
      end

      def execute(tasks, hosts)
        Log.debug("SSH execution tasks [#{Array(tasks).size}]")
        Log.debug("SSH on hosts [#{hosts.join(",")}]")
        Array(hosts).each do |host|
          session = ssh_session(host)
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
        password = config[:password]
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
              c.send_data("#{password}\n") if data =~ /^blender sudo password: /
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
        Log.debug("Invoking ssh: #{user}@#{host}")
        Net::SSH.start(host, user, config)
      end

      def fixup_sudo(command)
        command.sub(/^sudo/, 'sudo -p \'blender sudo password: \'')
      end
    end
  end
end
