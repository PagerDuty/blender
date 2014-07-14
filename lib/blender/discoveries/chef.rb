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

require 'chef/search/query'

module Blender
  module Discovery
    class ChefDiscovery
      attr_reader :options
      def initialize(options = {})
        @options = options
      end

      def search(search_term = '*:*')
        if options[:config_file]
          Chef::Config.from_file options[:config_file]
        end
        if options[:node_name]
          Chef::Config[:node_name] = options[:node_name]
        end
        if options[:client_key]
          Chef::Config[:client_key] = options[:client_key]
        end
        attr = options[:attribute] || 'fqdn'
        q = Chef::Search::Query.new
        res = q.search(:node, search_term)
        res.first.collect{|n| node_attribute(n, attr)}
      end

      private
      def node_attribute(data, nested_value_spec)
        nested_value_spec.split(".").each do |attr|
          if data.nil?
            nil # don't get no method error on nil
          elsif data.respond_to?(attr.to_sym)
            data = data.send(attr.to_sym)
          elsif data.respond_to?(:[])
            data = data[attr]
          else
            data = begin
              data.send(attr.to_sym)
            rescue NoMethodError
              nil
            end
          end
        end
        ( !data.kind_of?(Array) && data.respond_to?(:to_hash) ) ? data.to_hash : data
      end
    end
  end
end
