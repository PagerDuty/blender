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
  module Utils
    module Refinements
      def camelcase(string)
        str = string.dup
        str.gsub!(/[^A-Za-z0-9_]/, '_')
        rname = nil
        regexp = %r{^(.+?)(_(.+))?$}
        mn = str.match(regexp)
        if mn
          rname = mn[1].capitalize
          while mn && mn[3]
            mn = mn[3].match(regexp)
            rname << mn[1].capitalize if mn
          end
        end
        rname
      end

      def symbolize(hash)
        res = {}
        hash.keys.each do |k|
          res[k.to_sym] = hash[k]
        end
        res
      end
    end
  end
end
