# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/ghostinspector/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-ghostinspector"
  spec.version       = Capistrano::Ghostinspector::VERSION
  spec.authors       = ["Steven Richardson"]
  spec.email         = ["steven@richdynamix.com"]
  spec.summary       = "Ghost Inspector - Capistrano"
  spec.description   = "A Ghost Inspector plugin for Capistrano"
  spec.homepage      = 'http://rubygems.org/gems/capistrano-ghostinspector'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'capistrano', "~> 2.15.5"
  spec.add_dependency 'staccato'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'capistrano-spec'
end
