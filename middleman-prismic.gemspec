# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-prismic/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-prismic"
  spec.version       = MiddlemanPrismic::VERSION
  spec.authors       = ["Filippos Vasilakis"]
  spec.email         = ["vasilakisfil@gmail.com"]

  spec.summary       = %q{Middleman extension for Prismic}
  spec.description   = %q{Middleman extension for Prismic}
  spec.homepage      = "https://github.com/kollegorna/middleman-prismic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "middleman-cli", "~> 4.2"
  spec.add_runtime_dependency "middleman-core", "~> 4.2"
  spec.add_runtime_dependency "prismic.io", "~> 1.6"
end
