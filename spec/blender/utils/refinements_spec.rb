require 'spec_helper'
require 'blender/utils/refinements'

describe Blender::Utils::Refinements do
  let(:util) do
    Object.new.extend described_class
  end
  it '#camelcase' do
    expect(util.camelcase('one')).to eq('One')
    expect(util.camelcase('one_two')).to eq('OneTwo')
    expect(util.camelcase('one_two_three')).to eq('OneTwoThree')
    expect(util.camelcase('o_n_e')).to eq('ONE')
    expect(util.camelcase('One')).to eq('One')
    expect(util.camelcase('onE')).to eq('One')
  end
end
