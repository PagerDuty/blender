# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blender/version'

Gem::Specification.new do |spec|
  spec.name          = "blender"
  spec.version       = Blender::VERSION
  spec.authors       = ["Ranjib Dey"]
  spec.email         = ["ranjib@pagerduty.com"]
  spec.summary       = %q{Poor man's orchestration engine}
  spec.description   = %q{Service discovery, orchestration, remote command dispatch and a DSL layer}
  spec.homepage      = "http://github.com/PagerDuty/blender"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mixlib-log'
  spec.add_dependency 'mixlib-shellout'
  spec.add_dependency 'highline'
  spec.add_dependency 'net-ssh'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
