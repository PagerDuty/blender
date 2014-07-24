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

require 'blender/exceptions'
require 'blender/log'
require 'blender/drivers/serf'
require 'json'
require 'blender/tasks/serf'

module Blender
  module Driver
    class SerfAsync < Serf

      def dup_command(cmd, payload)
        Blender::Task::Serf::SerfQuery.new(
          cmd.query,
          payload,
          cmd.timeout,
          cmd.noack
        )
      end

      def start!(cmd, host)
        resps = serf_query(dup_command(cmd, 'start'), host)
        status = extract_status!(resps.first)
        unless status == 'success'
          raise Blender::Exceptions::SerfAsyncJobError, "Failed to start async serf job. Status = #{status}"
        end
      end

      def finished?(cmd, host)
        Blender::Log.debug("Checking for status")
        resps = serf_query(dup_command(cmd, 'check'), host)
        Blender::Log.debug("Responses: #{resps.inspect}")
        Blender::Log.debug("Status:#{extract_status!(resps.first)}")
        extract_status!(resps.first) == 'finished'
      end

      def reap!(cmd, host)
        resps = serf_query(dup_command(cmd, 'reap'), host)
        extract_status!(resps.first) == 'success'
      end

      def run_command(command, host)
        begin
          start!(command, host)
          until finished?(command, host)
            sleep 10
          end
          reap!(command, host)
          ExecOutput.new(0, '', '')
        rescue StandardError => e
          ExecOutput.new( -1, '', e.message + e.backtrace.join("\n"))
        end
      end

      def extract_status!(res)
        payload = JSON.parse(res['Payload'])
        unless payload['code'].zero?
          raise Blender::Exceptions::SerfAsyncJobError, "non zero query response code: #{res}"
        end
        Blender::Log.debug("Payload: #{payload['result'].inspect}")
        payload['result']['status']
      end
    end
  end
end
