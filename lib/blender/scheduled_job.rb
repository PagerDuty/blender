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

module Blender
  # A scheduled job encapsulates a blender based job to be executed
  # at certain interval. Job is specified as a file path, where
  # the file contains job written in blender's DSL. Job interval can be
  # specified either via +cron+ or  +every+ method
  #
  # +Blender::Timer+ object uses +ScheduledJob+ and to execute the job
  # and Rufus::Scheduler to schedule it
  class ScheduledJob
    attr_reader :schedule, :file
    # create a new instance
    # @param name [String] name of the job
    def initialize(name)
      @name = name
      @file = nil
    end

    # set the path of the file holding blender job
    #
    # @param file [String] path of the blender file
    def blender_file(file)
      @file = file
    end

    # set the job inteval via cron syntax. The value is passed as it  is
    # to rufus scheduler.
    #
    # @param line [String] job interval in cron syntax e.g (*/5 * * * *)
    def cron(line)
      @schedule = [ __method__, line]
    end

    # set the job inteval after every specified seconds
    # to rufus scheduler.
    #
    # @param interval [Fixnum] job interval in seconds
    def every(interval)
      @schedule = [ __method__, interval]
    end

    # invoke a blender run based on the +blender_file+
    def run
      des = File.read(@file)
      Blender.blend(@file) do |sch|
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end
  end
end
