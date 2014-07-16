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

require 'blender/log'

module Blender
  module Driver
    class Base
      attr_reader :config

      ExecOutput = Struct.new(:exitstatus, :stdout, :stderr)

      def initialize(config = {})
        @events = config.delete(:events) or fail 'Events needed'
        @config = default_config.merge(config)
      end

      def converge_by(desc)
        if config[:why_run]
          @events.skipping_for_why_run(desc)
        else
          yield
        end
      end

      def evaluate_guards?(task)
        if task.guards[:not_if].empty? and task.guards[:only_if].empty?
          false
        else
          task.guards[:not_if].all? do |command|
            raw_exec(command).exitstatus == 0
          end and
          task.guards[:only_if].all? do |command|
            raw_exec(command).exitstatus != 0
          end
        end
      end

      # returns 0 upon success
      def raw_exec(command)
        raise RuntimeError, 'this method must be overridden'
      end

      def execute(tasks, hosts)
        raise RuntimeError, 'this method must be overridden'
      end

      def stdout
        @config[:stdout]
      end

      def stderr
        @config[:stdout]
      end

      private
      def default_config
        {
          timout: 60, 
          ignore_failure: false,
          why_run: false,
          stdout: File.open(File::NULL, 'w'),
          stdout: File.open(File::NULL, 'w')
        }
      end
    end
  end
end
