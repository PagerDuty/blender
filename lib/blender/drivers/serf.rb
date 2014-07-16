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

module Blender
  module Driver
    class Serf < Base

      def filter_by
        @config[:filter_by]
      end

      def serf_query(command, host)
        responses = []
        Log.debug("Invoking serf query '#{command.query}' with payload '#{command.payload}' against #{@current_host}")
        Log.debug("Serf RPC address #{@config[:host]}:#{@config[:port]}")
        serf_config = {
          host: @config[:host],
          port: @config[:port],
          authkey: @config[:authkey]
        }
        Serfx.connect(serf_config) do |conn|
          conn.query(*query_opts(command, host)) do |event|
            responses <<  event
            puts event.inspect
          end
        end
        responses
      end

      def raw_exec(command, host)
        responses = serf_query(command, host)
        ExecOutput.new(exit_status(responses), responses.inspect, '')
      end

      def exit_status(responses)
        case filter_by
        when :host
          responses.size == 1 ? 0 : -1
        when :tag
          0
        else
          raise ArgumentError, "Unknown filter_by option: #{@config[:filter_by]}"
        end
      end

      def query_opts(command, host)
        opts = { Timeout: (command.timeout || 15)*1e9.to_i}
        case filter_by
        when :host
          opts.merge!(FilterNodes: [host])
        when :tag
          opts.merge!(FilterTags: {@config[:filter_tag] => host})
        else
          raise ArgumentError, "Unknown filter_by option: #{@config[:filter_by]}"
        end
        [ command.query, command.payload, opts]
      end

      def execute(job)
        tasks = job.tasks
        hosts = job.hosts
        Log.debug("Serf execution tasks [#{tasks.inspect}]")
        Log.debug("Serf query on #{filter_by}s [#{hosts.inspect}]")
        Array(hosts).each do |host|
          Array(tasks).each do |task|
            if evaluate_guards?(task)
              Log.debug("#{filter_by}:#{host}| Guards are valid")
            else
              Log.debug("#{filter_by}:#{host}| Guards are invalid")
              run_task_command(task, host)
            end
          end
        end
      end

      def run_task_command(task, host)
         e_status = raw_exec(task.command, host).exitstatus
         if e_status != 0
           if task.metadata[:ignore_failure]
             Log.warn('Ignore failure is set, skipping failure')
           else
            raise Exceptions::ExecutionFailed, "Failed to execute '#{task.command}'"
           end
         end
      end

      private
      def default_config
        super.merge(filter_by: :host)
      end
    end
  end
end
