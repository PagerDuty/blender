require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = %w(spec/**/*_spec.rb)
  t.rspec_opts =%w(-t ~fork) if RUBY_PLATFORM == 'java'
end

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = %w(spec/**/*_rspec.rb)
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w(Rakefile Gemfile lib/**/*.rb)
  t.fail_on_error = true
end

task default: [:spec, :rubocop]
