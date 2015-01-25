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

require 'spec_helper'

describe Blender::Configuration do
  it 'should populate argments and noop key' do
    expect(Blender::Configuration[:noop]).to be(false)
    expect(Blender::Configuration[:argments]).to be_empty
  end
  it 'should set configs globally' do
    Blender::Configuration[:x] = 1
    expect(Blender::Configuration[:x]).to eq(1)
  end
  it 'should reset config' do
    Blender::Configuration[:x] = 1
    Blender::Configuration.reset!
    expect(Blender::Configuration[:x]).to be_empty
  end
end
