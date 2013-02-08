# -*- encoding: utf-8 -*-
require File.expand_path("../lib/progressbar", __FILE__)

Gem::Specification.new do |s|
  s.name        = "progressbar"
  s.version     = ProgressBar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Satoru Takabayashi", "Jose Peleteiro"]
  s.email       = ["satoru@0xcc.net", "jose@peleteiro.net"]
  s.homepage    = "http://github.com/peleteiro/progressbar"
  s.summary     = "Ruby/ProgressBar is a text progress bar library for Ruby."
  s.description = "Ruby/ProgressBar is a text progress bar library for Ruby. It can indicate progress with percentage, a progress bar, and estimated remaining time."
  s.license     = "Ruby"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "minitest", ">= 0"
  s.add_development_dependency "yard", ">= 0"
  s.add_development_dependency "rake", ">= 0"
  s.add_development_dependency "simplecov", ">= 0.3.5"
  s.add_development_dependency "bluecloth", ">= 0.3.5"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8"]
end
