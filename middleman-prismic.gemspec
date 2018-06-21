# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-prismic/version"

Gem::Specification.new do |spec|
  spec.name = "middleman-prismic"
  spec.version = MiddlemanPrismic::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Filippos Vasilakis"]
  spec.email = ["vasilakisfil@gmail.com"]

  spec.summary       = %q{Middleman extension for Prismic}
  spec.description   = %q{Middleman extension for Prismic}
  spec.homepage      = "https://github.com/kollegorna/middleman-prismic"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "middleman-core", ">= 4.2.1"
  spec.add_runtime_dependency "middleman-cli", ">= 4.2.1"
  spec.add_runtime_dependency "prismic.io", "~> 1.6"
end
