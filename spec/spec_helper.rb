
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require 'blender'
require 'blender/scheduling_strategies/per_host'
require 'blender/scheduling_strategies/per_task'

module SpecHelper
  def create_task(name, driver = nil)
    t = Blender::Task::Base.new(name)
    if driver
      t.use_driver(driver)
    end
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
  config.backtrace_exclusion_patterns = []
end
