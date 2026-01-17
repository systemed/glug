# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'glug'
  s.version     = '0.0.8'
  s.date        = '2022-11-23'
  s.summary     = 'Glug'
  s.description = 'Text-based markup for Mapbox GL styles'
  s.authors     = ['Richard Fairhurst']
  s.email       = 'richard@systemeD.net'
  s.files       = Dir['README.md', 'lib/**/*']
  s.homepage    = 'http://github.com/systemed/glug'
  s.license     = 'FTWPL'
  s.required_ruby_version = '>= 2.7.0'
  s.add_dependency 'chroma'
  s.add_dependency 'hsluv'
  s.add_dependency 'neatjson'
  s.executables << 'glug'
end
