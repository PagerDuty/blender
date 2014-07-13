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
  class ScheduledJob
    attr_reader :schedule
    def initialize(name)
      @name = name
      @file = nil
    end

    def blender_file(file)
      @file = file
    end

    def cron(line)
      @schedule = [ __method__, line]
    end

    def every(*args)
      @schedule = [ __method__, args]
    end

    def run
      des = File.read(@file)
      Blender.blend(@file) do |sch|
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end
  end
end
