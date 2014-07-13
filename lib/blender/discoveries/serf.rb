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

require 'serfx'

module Blender
  module Discovery
    class SerfDiscovery
      def initialize(opts)
        @config = opts
      end
      def search(opts = {})
        tags = opts[:tags] || {}
        status = opts[:status] || 'alive'
        name = opts[:name]
        hosts = []
        Serfx.connect(@config) do |conn|
          conn.members_filtered(tags, status, name).body['Members'].map do |m|
            hosts << m['Name']
          end
        end
        hosts
      end
    end
  end
end
