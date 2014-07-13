require 'spec_helper'

describe Blender::EventDispatcher do
  let(:dispatcher) do
    described_class.new
  end
  subject(:handler){ Object.new}
  it '#register' do
    dispatcher.register(handler)
    expect(dispatcher.handlers).to include(handler)
  end
  it 'should forward all methods to the registered handlers' do
    dispatcher.register(handler)
    expect(handler).to receive(:run_started)
    dispatcher.run_started
  end
end
