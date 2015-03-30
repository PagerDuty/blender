require 'spec_helper'

describe Blender::Task::Blend do
  let(:task) do
    described_class.new('blend-test')
  end

  it 'setup task name accordingly' do
    expect(task.name).to eq('blend-test')
  end

  it 'setup blender file accordingly' do
    task.execute '/foo/bar'
    expect(task.command.file).to eq('/foo/bar')
  end

  it 'setup strategy for the blender job accordingly' do
    task.strategy :foo
    expect(task.command.strategy).to eq(:foo)
  end

  it 'setup concurrency correctly' do
    task.concurrency(10)
    expect(task.command.concurrency).to eq(10)
  end

  it 'setup explicit config accordingly' do
    task.config(:foo, bar: 'baz')
    expect(task.command.config_store[:foo]).to eq(bar: 'baz')
  end

  it 'has empty config by default' do
    expect(task.command.config_store).to be_empty
  end

  it 'specifies the list of configs copied correctly' do
    task.pass_configs :foo, :bar, :baz
    expect(task.command.pass_configs).to eq([:foo, :bar, :baz])
    expect(task.command.config_store).to be_empty
  end
end
