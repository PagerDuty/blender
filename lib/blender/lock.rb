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
  module Lock
    include  Blender::Utils::Refinements

    class Flock
      def initialize(options)
        @path = options['path']
      end
      def with_lock
        File.open(@path, File::CREAT, 0644) do |f|
          f.flock(File::LOCK_EX)
          yield if block_given?
        end
        File.unlink(@path)
      end
    end

    def lock(opts = {})
      lock_klass = Lock.const_get(camelcase(Configuration[:lock]['driver']).to_sym)
      options = Configuration[:lock]['options'].merge(opts)
      lock_klass.new(options).with_lock do
        yield if block_given?
      end
    end
  end
end
