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

require 'singleton'

module Blender
  module RSpec
    class SearchStub
      attr_reader :type, :opts, :return_value
      def initialize(type, opts)
        @type = type
        @opts = opts
      end
      def and_return(value)
        @return_value = value
      end
    end
    class StubRegistry
      include Singleton
      attr_reader :data
      def initialize
        @data = []
      end
      def self.add(type, opts)
        obj = SearchStub.new(type, opts)
        instance.data << obj
        obj
      end
    end
  end
end
