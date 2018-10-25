lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'citadel-ruby-client/version'
Gem::Specification.new do |s|
  s.name        = 'citadel-ruby-client'
  s.version     = Citadel::VERSION
  s.date        = '2018-10-17'
  s.summary     = 'Citadel Ruby client'
  s.description = 'A simple way to publish messages on Citadel'
  s.authors     = ['Claire Dufetrelle']
  s.email       = ['claire.dufetrelle@fabernovel.com']
  s.homepage    =
    'http://rubygems.org/gems/citadel-ruby-client'
  s.license       = 'MIT'
  s.files         = %w(
    lib/citadel-ruby-client.rb
    lib/citadel-ruby-client/authenticator.rb
    lib/citadel-ruby-client/matrix_interceptor.rb
    lib/citadel-ruby-client/matrix_paths.rb
    lib/citadel-ruby-client/version.rb
    )
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_dependency 'http', '~>3.3'
  s.add_dependency 'json', '~> 2.1', '>= 1.8.3'
end
