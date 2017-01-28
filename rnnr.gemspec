# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rnnr/version'

Gem::Specification.new do |spec|
  spec.name          = "rnnr"
  spec.version       = Rnnr::VERSION
  spec.authors       = ["Greg Merritt"]
  spec.email         = ["gremerritt@gmail.com"]

  spec.summary       = %q{Daily running reports}
  spec.description   = %q{Daily running reports. Send daily year-to-date running totals}
  spec.homepage      = "https://www.github.com/gremerritt/rnnr"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|pkg)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "commander", "~> 4.4"
  spec.add_dependency "faraday", "~> 0.11"
  spec.add_dependency "launchy", "~> 2.4"
  spec.add_dependency "mail"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
