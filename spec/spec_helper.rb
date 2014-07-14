require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec/'
  add_filter '.bundle'
end
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require 'blender'

module SpecHelper
  def create_task(name, driver = nil)
    t = Blender::Task::Base.new(name)
    if driver
      t.use_driver(driver)
    end
    t
  end
  def create_serf_task(name)
    Blender::Task::SerfTask.new(name).tap do |t|
      t.query 'test-query'
      t.payload 'test-payload'
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelper
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
  config.before(:each) do
    doc = double(Blender::Handlers::Doc).as_null_object
    allow(Blender::Handlers::Doc).to receive(:new).and_return(doc)
  end
end
