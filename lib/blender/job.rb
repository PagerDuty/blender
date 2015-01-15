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

require 'blender/exceptions'
require 'blender/log'
require 'blender/configuration'

module Blender
  # A job represent encapsulates an array of tasks to be performed
  # against an array of hosts. Jobs are created by scheduling strategies,
  # and passed to underlying drivers for execution
  # Tasks within a single job must has exactly same driver.
  class Job
    attr_reader :tasks, :hosts, :driver, :id

    # creates a new job
    # @param id [Fixnum] a numeric identifier
    # @param driver [Blender::Driver::Base] a driver object
    # @patam hosts [Array] list of target hosts
    # @patam hosts [Array] list of tasks to be run against the hosts
    def initialize(id, driver, tasks, hosts)
      @id = id
      @tasks = Array(tasks)
      @hosts = Array(hosts)
      @driver = driver
    end

    def run
      driver.execute(tasks, hosts) unless Configuration[:noop]
    end

    def to_s
      "Job #{id} [#{name}]"
    end

    # computes, momoize and return the name of the job
    # name is used to summarize the job.
    # @return [String]
    def name
      @name ||= compute_name
    end

    private
    def compute_name
      if tasks.size == 1
        t_part = tasks.first.name
      else
        t_part = "#{tasks.size} tasks"
      end
      if hosts.size == 1
        h_part = hosts.first
      else
        h_part = "#{hosts.size} members"
      end
      "#{t_part} on #{h_part}"
    end
  end
end
