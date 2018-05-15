Gem::Specification.new do |s|
  s.name        = 'glug'
  s.version     = '0.0.5'
  s.date        = '2018-05-15'
  s.summary     = "Glug"
  s.description = "Text-based markup for Mapbox GL styles"
  s.authors     = ["Richard Fairhurst"]
  s.email       = 'richard@systemeD.net'
  s.files       = ["lib/glug.rb"]
  s.homepage    = 'http://github.com/systemed/glug'
  s.license     = 'FTWPL'
  s.add_dependency 'neatjson'
  s.executables << 'glug'
end
