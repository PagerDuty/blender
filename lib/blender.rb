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
require 'json'
require 'blender/configuration'

# Top level module that holds all blender related libraries under this namespace
module Blender
  # Trigger a blender run. If a block is given, then an object of
  # Blender::Scheduler is yielded, otherwise the argument is treated as a
  # command and executed with local shellout driver
  #
  # @param name [String] Name of the run
  #
  # @return [void]
  def self.blend(name, config_file = nil)
    scheduler = Scheduler.new(name)
    if config_file
      configure(config_file)
    end
    if block_given?
      yield scheduler
    else
      scheduler.task(name)
    end
    scheduler.run
    scheduler
  end

  def self.configure(file)
    data = JSON.parse(File.read(file))
    if data['log_level']
      Blender::Log.level = data['log_level'].to_sym
    end
    if data['log_file']
      Blender::Log.init(data['log_file'])
    end
    if data['load_paths']
      data['load_paths'].each do |path|
        $LOAD_PATH.unshift(path)
      end
    end
    if data['scheduler']
      data['scheduler'].each do |key, value|
        Blender::Configuration[key.to_sym] = value
      end
    end
  end
end
