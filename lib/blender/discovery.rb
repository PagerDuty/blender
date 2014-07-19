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
require 'blender/utils/refinements'

module Blender
  module Discovery
    include Blender::Utils::Refinements
    def build_discovery(type, opts = {})
      disco_klass = Blender::Discovery.const_get(camelcase(type.to_s).to_sym)
      disco_klass.new(opts)
    end

    def serf_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:serf, options).search(search_opts)
    end

    def chef_discover(options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(:chef, options).search(search_opts)
    end
  end
end
