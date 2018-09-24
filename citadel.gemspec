lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "citadel/version"
Gem::Specification.new do |s|
  s.name        = 'citadel'
  s.version     = Citadel::VERSION
  s.date        = '2018-09-21'
  s.summary     = "Citadel SDK"
  s.description = "A simple way to publish messages on Citadel"
  s.authors     = ["Claire Dufetrelle"]
  s.email       = ['claire.dufetrelle@fabernovel.com']
  s.homepage    =
    'http://rubygems.org/gems/citadel'
  s.license       = 'MIT'
  s.files         = %w(
    lib/citadel.rb
    lib/citadel/authenticator.rb
    lib/citadel/matrix_interceptor.rb
    lib/citadel/matrix_paths.rb
    lib/citadel/version.rb
    )
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_dependency 'http'
  s.add_dependency 'json'
end