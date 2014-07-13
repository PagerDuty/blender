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

require 'blender/version'
require 'blender/scheduler'
require 'blender/log'
require 'blender/drivers/shellout'

# Top level module that holds all blender related libraries under this namespace
module Blender
  # Trigger a blender job. If a block is given, then an object of
  # Blender::Scheduler is yielded, othewise the argument is treated as a
  # command and executed locally
  #
  # @param name [String] Name of the job
  #
  # @return [void]
  def self.blend(name)
    if block_given?
      Log.debug('Advance blending in progress...')
      scheduler = Scheduler.new(name)
      yield scheduler
    else
      Log.debug('Newbie blending in progress...')
      scheduler = Scheduler.new(name)
      scheduler.task(name)
    end
    scheduler.run
    nil
  end

  # Trigger a blender job in the background and returns the pid of the
  # background process. Behaves exactly same as Blender#blend. When a block
  # is passed, an object of Blended::Scheduler is yielded, else the name is
  # treated as command and executed using shellout driver locally
  #
  # @param name [String] name of the job
  #
  # @return [Fixnum] pid of the background process
  def self.blend_async(name)
    Log.debug('Blending in background!')
    pid = fork do
      blend(name)
    end
    Process.detach(pid)
    Log.debug("Blender PID:#{pid}")
    pid
  end
end
