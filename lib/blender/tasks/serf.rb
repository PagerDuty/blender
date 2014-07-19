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
    class Serf < Blender::Task::Base


      SerfQuery = Struct.new(:query, :payload, :timeout, :noack, :process)

      def initialize(name, metadata = {})
        super
        @command = SerfQuery.new
        @command.query = name
      end

      def execute(&block)
        @command.instance_eval(&block)
      end

      def query(q)
        @command.query = q
      end

      def timeout(t)
        @command.timeout = t
      end

      def payload(pl)
        @command.payload = pl
      end

      def no_ack(bool)
        @command.noack = bool
      end

      def process(callback)
        @command.process = callback
      end

      def command
        @command
      end
    end
  end
end
