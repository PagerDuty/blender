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
    class Ruby < Blender::Task::Base

      attr_reader :code_block

      def not_if(&block)
        @guards[:not_if] << block
      end

      def only_if(&block)
        @guards[:only_if] << block
      end

      def execute(&block)
        @command = block
      end
    end
  end
end
