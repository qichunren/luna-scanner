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
  spec.homepage      = "https://git.g77k.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.bindir = 'bin'

  spec.add_runtime_dependency "net-ssh", "~> 2.7.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
