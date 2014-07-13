#require 'simplecov'
#SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
#SimpleCov.start { add_filter '/spec/' }
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require 'blender'
module SpecHelper
  def task_with_driver(name, driver)
    t = Blender::Task::Base.new(name)
    t.use_driver(driver)
    t
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
