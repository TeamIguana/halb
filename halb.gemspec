Gem::Specification.new do |s|
  s.name        = "halb"
  s.version     = '0.6.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TeamIguana"]
  s.summary     = 'Manage deploys behind HA.D/LDirector/LVS/HAProxy Load Balancers'
  s.homepage    = 'https://github.com/TeamIguana/halb'

  s.add_runtime_dependency('rake')
  s.add_runtime_dependency('net-ssh')

  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')

  s.files        = Dir.glob("{lib}/**/*.rb")
  s.require_paths = ['lib']
end