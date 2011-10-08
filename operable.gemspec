lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'operable/version'

Gem::Specification.new do |s|

  s.name = 'operable'
  s.version = Operable::VERSION
  s.authors = ['Jason Coene']
  s.email = ['jcoene@gmail.com']
  s.homepage = 'http://github.com/jcoene/operable'
  s.summary = 'Convenient operations for your models.'
  s.description = 'Operable is the easiest way to perform common operations on multiple instances of a model.'

  s.add_dependency 'activemodel', '~> 3.0'

  s.add_development_dependency 'activerecord', '~> 3.0.0'
  s.add_development_dependency 'mongoid', '~> 2.0'
  s.add_development_dependency 'bson_ext', '~> 1.3'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'guard-rspec', '~> 0.4.3'

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.md"]
  s.require_paths = ['lib']

end
