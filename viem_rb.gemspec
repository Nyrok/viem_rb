# frozen_string_literal: true

require_relative "lib/viem/version"

Gem::Specification.new do |spec|
  spec.name          = "viem_rb"
  spec.version       = Viem::VERSION
  spec.authors       = ["Nyrok"]
  spec.email         = ["nyrokgaming1@gmail.com"]
  spec.summary       = "Ruby adaptation of viem — Ethereum interface for Rails"
  spec.description   = "A Ruby/Rails adaptation of the viem TypeScript library. " \
                       "Provides Ethereum clients, ABI encoding/decoding, account management, " \
                       "and utilities for Ruby on Rails 7+ applications."
  spec.homepage      = "https://github.com/Nyrok/viem_rb"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["lib/**/*", "README.md", "CHANGELOG.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "eth",        "~> 0.5"
  spec.add_dependency "faraday",    "~> 2.0"
  spec.add_dependency "websocket-client-simple", "~> 0.3"

  spec.add_development_dependency "rspec",   "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.metadata["rubygems_mfa_required"] = "true"
end
