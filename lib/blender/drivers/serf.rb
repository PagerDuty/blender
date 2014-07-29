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

      attr_reader :filter_by, :concurrency, :filter_tag

      def initialize(config = {})
        cfg = config.dup
        @filter_by =  cfg.delete(:filter_by) || :host
        @concurrency = cfg.delete(:concurrency) || 1
        if @filter_by == :tag
          @filter_tag =  cfg.delete(:filter_tag)
          raise ArgumentError, 'Must specify filter_tag when filter_by is set to :tag' unless @filter_tag
        end
        super(cfg)
      end

      def serf_query(command, host)
        responses = []
        Log.debug("Invoking serf query '#{command.query}' with payload '#{command.payload}' against #{@current_host}")
        Log.debug("Serf RPC address #{config[:host]}:#{config[:port]}")
        Serfx.connect(config) do |conn|
          conn.query(*query_opts(command, host)) do |event|
            responses <<  event
            stdout.puts event.inspect
          end
        end
        responses
      end

      def run_command(command, nodes)
        begin
          responses = serf_query(command, nodes)
          if command.process
            command.process.call(responses)
          end
          ExecOutput.new(exit_status(responses, nodes), responses.inspect, '')
        rescue StandardError => e
          ExecOutput.new( -1, '', e.message)
        end
      end

      def exit_status(responses, nodes)
        case filter_by
        when :host
          responses.size == nodes.size ? 0 : -1
        when :tag, :none
          0
        else
          raise ArgumentError, "Unknown filter_by option: #{filter_by}"
        end
      end

      def query_opts(command, nodes)
        opts = { Timeout: (command.timeout || 15)*1e9.to_i}
        case filter_by
        when :host
          opts.merge!(FilterNodes: nodes)
        when :tag
          raise 'filter by :tag only supports single tag' unless nodes.size == 1
          opts.merge!(FilterTags: {filter_tag => nodes.first})
        when :none
          raise 'filter by :none only supported with localhost' unless nodes == ['localhost']
        else
          raise ArgumentError, "Unknown filter_by option: #{filter_by}"
        end
        [ command.query, command.payload, opts]
      end

      def execute(tasks, hosts)
        Log.debug("Serf query on #{filter_by}s [#{hosts.inspect}]")
        tasks.each do |task|
          hosts.each_slice(concurrency) do |nodes|
            events.command_started(task.command)
            cmd = run_command(task.command, nodes)
            events.command_finished(task.command, cmd)
            if cmd.exitstatus != 0 and !task.metadata[:ignore_failure]
              raise Exceptions::ExecutionFailed, cmd.stderr
            end
          end
        end
      end
    end
  end
end
