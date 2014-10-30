$:.unshift File.expand_path("../lib", __FILE__)
require "mengpaneel/version"

Gem::Specification.new do |spec|
  spec.name          = "mengpaneel"
  spec.version       = Mengpaneel::VERSION
  spec.author        = "Douwe Maan"
  spec.email         = "douwe@selenight.nl"
  spec.summary       = "Mengpaneel makes Mixpanel a breeze to use in Rails apps."
  spec.description   = "Mengpaneel gives you a single way to interact with Mixpanel from your Rails controllers, with Mengpaneel taking it upon itself to make sure everything gets to Mixpanel."
  spec.homepage      = "https://github.com/DouweM/mengpaneel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]
  
  spec.add_dependency "activesupport"
  spec.add_dependency "mixpanel-ruby"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
