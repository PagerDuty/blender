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

require 'thor'
require 'blender'
require 'blender/timer'

module Blender
  class CLI < Thor
    def self.exit_on_failure?
      true
    end
    stop_on_unknown_option! :from_file
    check_unknown_options! except: :from_file

    default_command :from_file
    package_name 'Blender'

    desc 'from_file ', 'Run blender job from a file'
    method_option :file,
      default: 'Blendfile',
      type: :string,
      aliases: '-f'

    method_option :config_file,
      default: nil,
      type: :string,
      aliases: '-c',
      banner: 'Provide additional configuration via json file'

    method_option :noop,
      default: false,
      type: :boolean,
      aliases: '-n',
      banner: 'No-op mode, run blender without executing jobs'

    def from_file(*args)
      Configuration[:noop] = options[:noop]
      des = File.read(options[:file])
      $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(options[:file]), 'lib')))
      Blender.blend(options[:file], options[:config_file]) do |sch|
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end

    desc 'schedule', 'Run blender in daemon mode, with job scheduled in periodic interval'
    method_option :schedule,
      default: 'Schedule_it',
      type: :string,
      aliases: '-s'
    def schedule
      sched = Blender::Timer.new
      des = File.read(options[:schedule])
      sched.instance_eval(des, __FILE__, __LINE__)
      sched.join
    end
  end
end
