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
require 'serfx'
require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/base'
require 'blender/drivers/serf'
require 'json'
require 'pry'

module Blender
  module Driver
    class SerfAsync < Serf
      def raw_exec(command)
        command.payload = 'start'
        start_responses = serf_query(command)
        loop do
          sleep(@config[:check_interval])
          break if command_finished?(command, start_responses)
        end
        ExecOutput.new(exit_status(responses), responses.inspect, '')
      end

      def command_finished?(command, start_responses)
        cmd = command.dup.tap{|c|c.payload = 'check'}
        check_responses = serf_query(cmd)
      end

      def reap_command?(command, start_responses)
        cmd = command.dup.tap{|c|c.payload = 'reap'}
        check_responses = serf_query(comd)
      end

      private
      def default_config
        super.merge(check_interval: 60)
      end
    end
  end
end
