# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payment_schedule/version'

Gem::Specification.new do |spec|
  spec.name                  = "payment_schedule"
  spec.version               = PaymentSchedule::VERSION
  spec.authors               = ["Murdho"]
  spec.email                 = ["murdho@murdho.com"]

  spec.summary               = %q{Mild toolset for changing payment schedule algorithms to lovely Ruby code.}
  spec.homepage              = "https://github.com/murdho/paymeny_schedule"
  spec.license               = "MIT"
  spec.required_ruby_version = '>= 2.4.0'

  spec.files                 = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|examples)/})
  end
  spec.bindir                = "exe"
  spec.executables           = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths         = ["lib"]

  spec.add_runtime_dependency "terminal-table", "~> 1.7"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "simplecov", "~> 0.13"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "awesome_print", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0"
end
