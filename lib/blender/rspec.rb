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

begin
  require 'rspec'
  require 'rspec/mocks'
rescue LoadError
  abort 'Blender::RSpec requires RSpec, RSpec::Mocks'
end

require 'blender'
require 'blender/rspec/stub_registry'

module Blender
  module Discovery
    alias_method :old_search, :search
    def search(type, options = nil)
      stub = Blender::RSpec::StubRegistry.instance.data.detect do |st|
        st.type == type && st.opts == options
      end
      if stub
        stub.return_value
      else
        old_search(type, options)
      end
    end
  end
  class Utils::UI
    def puts(string)
    end
  end

  module RSpec
    extend self
    include Blender::Utils::Refinements
    def stub_search(type, options = nil)
      StubRegistry.add(type, options)
    end

    def noop_scheduler_from_file(file)
      Blender::Configuration[:noop] = true
      des = File.read(file)
      $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(file), 'lib')))
      Blender.blend(file) do |sch|
        sch.lock_options(nil)
        sch.instance_eval(des, __FILE__, __LINE__)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Blender::RSpec
end
