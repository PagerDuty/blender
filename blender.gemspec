# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blender/version'

Gem::Specification.new do |spec|
  spec.name          = 'blender'
  spec.version       = Blender::VERSION
  spec.authors       = ['Ranjib Dey']
  spec.email         = ['ranjib@pagerduty.com']
  spec.summary       = %q{Execute jobs acorss a set of servers using ssh or serf}
  spec.description   = %q{Discover and execute ordered jobs across your fleet}
  spec.homepage      = 'http://github.com/PagerDuty/blender'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chef'
  spec.add_dependency 'highline'
  spec.add_dependency 'thor'
  spec.add_dependency 'mixlib-shellout'
  spec.add_dependency 'mixlib-log'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'serfx'
  spec.add_dependency 'rufus-scheduler'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
