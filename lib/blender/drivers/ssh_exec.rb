#
# Author:: Ranjib Dey (<ranjib@pagerduty.com>)
# Author:: Smit Shah (<who828@gmail.com>)
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

require 'blender/log'
module Blender::Driver::SSHExec
  def remote_exec(command, session)
    password = config[:password]
    command = fixup_sudo(command)

    command_results = ThreadSafe::Hash.new do |command_results, host|
      command_results[host] = Blender::Driver::Base::ExecOutput.new(
        0,
        Tempfile.new('blender-stdout'),
        Tempfile.new('blender-stderr')
      )
    end
    channel = session.open_channel do |ch|
      command_result = command_results[ch.connection.host]
      ch.request_pty
      ch.exec(command) do |ch, success|
        unless success
          Blender::Log.debug("Command not found:#{success.inspect}")
          command_result.exitstatus = -1
        end
        ch.on_data do |c, data|
          command_result.stdout << data
          c.send_data("#{password}\n") if data =~ /^blender sudo password: /
        end
        ch.on_extended_data do |c, type, data|
          command_result.stderr << data
        end
        ch.on_request "exit-status" do |ichannel, data|
          command_result.exitstatus = data.read_long
          Blender::Log.debug("exit-status data:#{command_result.exitstatus}")
        end
        ch.on_close do |ch|
          command_result.stdout.rewind
          command_result.stderr.rewind
        end
      end
      Blender::Log.debug("Exit(#{command_result.exitstatus}) Command: '#{command}'")
    end
    channel.wait
    command_results
  end

  def fixup_sudo(command)
    command.sub(/^sudo/, 'sudo -p \'blender sudo password: \'')
  end
end
