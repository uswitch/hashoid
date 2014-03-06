# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hashoid/version'

Gem::Specification.new do |spec|
  spec.name          = "hashoid"
  spec.version       = Hashoid::VERSION
  spec.authors       = ["Thibaut Sacreste"]
  spec.email         = ["thibaut.sacreste@gmail.com"]
  spec.description   = "Hashoid: a JSON/Hash to Object Mapper"
  spec.summary       = "Turns your bland json/hashes into flavoursome objects!"
  spec.homepage      = "https://github.com/uswitch/hashoid"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "activesupport"
end
