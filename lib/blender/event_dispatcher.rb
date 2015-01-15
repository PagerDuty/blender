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
require 'blender/handlers/base'

module Blender
  class EventDispatcher
    attr_reader :handlers
    def initialize
      @handlers = []
    end

    def register(handler)
      @handlers << handler
    end

    # Define a method that will be forwarded to all
    def self.def_forwarding_method(method_name)
      class_eval(<<-END_OF_METHOD, __FILE__, __LINE__)
        def #{method_name}(*args)
          @handlers.each {|s| s.#{method_name}(*args)}
        end
      END_OF_METHOD
    end

   (Handlers::Base.instance_methods - Object.instance_methods).each do |method_name|
      def_forwarding_method(method_name)
    end
  end
end
