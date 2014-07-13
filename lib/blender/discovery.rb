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

require 'blender/discoveries/chef'
require 'blender/discoveries/serf'

module Blender
  module Discovery
    def self.get(type)
      case type.to_sym
      when :chef
        ChefDiscovery
      when :serf
        SerfDiscovery
      else
        raise 'Discovery method not sypported'
      end
    end

    def register_discovery(type, name, opts = {})
      @registered_discoveries[name] = Discovery.get(type).new(opts)
    end

    def discover_by(name, opts ={})
      @registered_discoveries[name].search(opts)
    end

    def discover(type, options = {})
      search_opts = options.delete(:search)
      Discovery.get(type).new(options).search(search_opts)
    end
  end
end
