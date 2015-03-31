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

require 'blender/tasks/base'

module Blender
  module Task
    class Blend < Base
      attr_reader :blender_strategy

      def initialize(name, metadata = {})
        super
        @command = Struct.new(
          :file,
          :strategy,
          :pass_configs,
          :config_store,
          :concurrency,
          :options
        ).new
        @command.strategy = :default
        @command.concurrency = 1
        @command.pass_configs = []
        @command.config_store = ThreadSafe::Cache.new
        @command.options = ThreadSafe::Hash.new
      end

      def strategy(st)
        @command.strategy = st
      end

      def execute(f)
        @command.file = f
      end

      alias file execute

      def concurrency(n)
        @command.concurrency = n
      end

      def pass_configs(*keys)
        @command.pass_configs += keys unless keys.empty?
      end

      def config(key, opts = {})
        @command.config_store[key] = opts
      end

      def options(hash)
        @command.options.merge!(hash)
      end
    end
  end
end
