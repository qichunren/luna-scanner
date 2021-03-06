# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'luna_scanner/version'

Gem::Specification.new do |spec|
  spec.name          = "luna_scanner"
  spec.version       = LunaScanner::VERSION
  spec.authors       = ["qichunren"]
  spec.email         = ["whyruby@gmail.com"]
  spec.description   = %q{Discover luna-client devices in LAN}
  spec.summary       = %q{Discover luna-clinet devices in LAN, batch config them.}
  spec.homepage      = "https://github.com/qichunren/luna-scanner"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.bindir = 'bin'

  spec.required_ruby_version = ">= 1.9.1"

  spec.add_runtime_dependency "net-ssh", "~> 2.7.0"
  spec.add_runtime_dependency "net-scp", "~> 1.1.2"
  spec.add_runtime_dependency "sinatra", "~> 1.4.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
