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

      attr_reader :metadata
      attr_reader :name
      attr_reader :hosts
      attr_reader :driver
      attr_reader :command
      attr_reader :driver_opts

      def initialize(name, metadata = {})
        @name = name
        @metadata = default_metadata.merge(metadata)
        @hosts = []
        @command = name
        @driver = nil
        @driver_opts = {}
      end

      def use_driver(driver)
        @driver = driver
      end

      def ignore_failure(value)
        @metadata[:ignore_failure] = value
      end

      def driver_options(opts)
        @driver_opts =  opts
      end

      def execute(cmd)
        @command = cmd
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
        { ignore_failure: false }
      end
    end
  end
end
