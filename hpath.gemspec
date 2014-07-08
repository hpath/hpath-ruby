# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hpath/version"

Gem::Specification.new do |spec|
  spec.name          = "hpath"
  spec.version       = Hpath::VERSION
  spec.authors       = ["Michael Sievers"]
  spec.summary       = %q{HPath for ruby}
  spec.homepage      = "https://github.com/hpath/hpath-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",   ">= 3.0.0", "< 4.0.0"
end
