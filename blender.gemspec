# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blender/version'

Gem::Specification.new do |spec|
  spec.name          = 'pd-blender'
  spec.version       = Blender::VERSION
  spec.authors       = ['Ranjib Dey']
  spec.email         = ['ranjib@pagerduty.com']
  spec.summary       = %q{A modular orchestration engine}
  spec.description   = %q{Discover hosts, run tasks against them and control their execution order}
  spec.homepage      = 'http://github.com/PagerDuty/blender'
  spec.license       = 'Apache 2'
  spec.bindir        = 'bin'
  spec.executables  = ['blend']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'highline'
  spec.add_dependency 'thor'
  spec.add_dependency 'mixlib-shellout'
  spec.add_dependency 'mixlib-log'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'net-ssh-multi'
  spec.add_dependency 'net-scp'
  spec.add_dependency 'rufus-scheduler'
  spec.add_dependency 'thread_safe'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
end
