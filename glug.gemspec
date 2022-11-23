Gem::Specification.new do |s|
  s.name        = 'glug'
  s.version     = '0.0.8'
  s.date        = '2022-11-23'
  s.summary     = "Glug"
  s.description = "Text-based markup for Mapbox GL styles"
  s.authors     = ["Richard Fairhurst"]
  s.email       = 'richard@systemeD.net'
  s.files       = ["lib/glug.rb", "lib/glug/condition.rb", "lib/glug/extensions.rb", "lib/glug/layer.rb", "lib/glug/stylesheet.rb"]
  s.homepage    = 'http://github.com/systemed/glug'
  s.license     = 'FTWPL'
  s.add_dependency 'neatjson'
  s.add_dependency 'chroma'
  s.add_dependency 'hsluv'
  s.executables << 'glug'
end
