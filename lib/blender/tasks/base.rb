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
require 'blender/discovery'

module Blender
  module Task
    class Base
      include Blender::Discovery
      attr_reader :guards, :metadata, :name, :hosts, :driver

      def initialize(name, metadata = {})
        @name = name
        @metadata = default_metadata.merge(metadata)
        @guards = {not_if: [], only_if: []}
        @hosts = []
        @driver = nil
        @before_hooks = []
        @after_hooks = []
      end

      def use_driver(driver)
        @driver = driver
      end

      def before(&block)
        @before_hooks << block
      end

      def after(&block)
        @after_hooks << block
      end

      def ignore_failure(value)
        @metadata[:ignore_failure] = value
      end

      def not_if(cmd)
        @guards[:not_if] << cmd
      end

      def only_if(cmd)
        @guards[:only_if] << cmd
      end

      def execute(cmd)
        @command = cmd
      end

      def command
        @command || name
      end

      def members(hosts)
        @hosts = hosts
      end

      def add_metadata(opts = {})
        opts.keys.each do |k|
          @metadata[k] = opts[k]
        end
      end

      def default_metadata
        {
        timout: 60,
        ignore_failure: false,
        retries: 0,
        retry_delay: 0,
        async: 0,
        handlers: []
        }
      end
    end
    class ShellOut < Base; end
  end
end
