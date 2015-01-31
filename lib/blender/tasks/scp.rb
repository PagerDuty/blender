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

require 'blender/tasks/ssh'
require 'forwardable'

module Blender
  module Task
    class Scp < Blender::Task::Base
      extend Forwardable
      def_delegators :@command, :direction, :direction=
      def initialize(name, metadata = {})
        super
        @command = Struct.new(:direction, :source, :target).new
        @command.target = name
        @command.source = name
        @direction = :upload
      end
      def from(source)
        @command.source = source
      end
      def to(target)
        @command.target = target
      end
    end
  end
end
