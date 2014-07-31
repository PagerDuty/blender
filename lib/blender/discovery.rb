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

require 'blender/utils/refinements'

module Blender
  module Discovery
    include Blender::Utils::Refinements

    def init(type, opts = {})
      discovery_config[type].merge!(opts).freeze
    end

    def build_discovery(type, opts = {})
      disco_klass = Blender::Discovery.const_get(camelcase(type.to_s).to_sym)
      disco_opts = discovery_config[type].merge(opts)
      disco_klass.new(disco_opts)
    end

    def search_with_config(type, options = {})
      search_opts = options.delete(:search) || {}
      build_discovery(type, options).search(search_opts)
    end

    def search(options = {})
      search_with_config(search: options)
    end
  end
end
