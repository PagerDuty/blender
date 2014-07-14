require 'spec_helper'

describe Blender::SchedulingStrategy do
  it '#get default' do
    expect(described_class.get(:default)).to be_kind_of(Blender::SchedulingStrategy::Default)
  end
  it '#get per_host' do
    expect(described_class.get(:per_host)).to be_kind_of(Blender::SchedulingStrategy::PerHost)
  end
end
