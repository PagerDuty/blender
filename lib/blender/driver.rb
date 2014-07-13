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

require 'blender/drivers/ssh'
require 'blender/drivers/shellout'
require 'blender/drivers/serf'
require 'blender/drivers/serf_multi'
require 'blender/drivers/serf_async'
require 'blender/drivers/ruby'

module Blender
  module Driver
    def self.get(type)
      case type.to_sym
      when :ssh
        Driver::Ssh
      when :local
        Driver::ShellOut
      when :ruby
        Driver::Ruby
      when :serf
        Driver::Serf
      when :serf_multi
        Driver::SerfMulti
      when :serf_async
        Driver::SerfAsync
      else
        raise ArgumentError, "Can not find driver of type '#{type.inspect}'"
      end
    end
  end
end
