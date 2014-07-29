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
      attr_reader :config, :events, :stdout, :stderr

      ExecOutput = Struct.new(:exitstatus, :stdout, :stderr)

      def initialize(config = {})
        cfg = config.dup
        @stdout = cfg.delete(:stdout) || File.open(File::NULL, 'w')
        @stderr = cfg.delete(:stderr) || File.open(File::NULL, 'w')
        @events = cfg.delete(:events) or fail 'Events needed'
        @config = cfg
      end

      def execute(tasks, hosts)
        raise RuntimeError, 'this method must be overridden'
      end
    end
  end
end
