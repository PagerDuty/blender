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

require 'mixlib/shellout'
require 'blender/drivers/local'

module Blender
  module Driver
    class ShellOut < Local
      def raw_exec(command)
        cmd = Mixlib::ShellOut.new(command)
        cmd.live_stream = config[:stdout]
        cmd.run_command
        ExecOutput.new(cmd.exitstatus, cmd.stdout, cmd.stderr)
      end
    end
  end
end
