lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'operable/version'

Gem::Specification.new do |s|

  s.name = 'operable'
  s.version = Operable::VERSION
  s.authors = ['Jason Coene']
  s.email = ['jcoene@gmail.com']
  s.homepage = 'http://github.com/jcoene/operable'
  s.summary = 'Arithmetic operations on your models.'
  s.description = 'Perform addition, subtraction, multiplication and division on your models.'

  s.add_dependency 'activemodel', '>= 3.0'

  s.add_development_dependency 'activerecord', '~> 3.0'
  s.add_development_dependency 'mongoid', '~> 2.3'
  s.add_development_dependency 'bson_ext', '~> 1.4'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0.rc1'
  s.add_development_dependency 'guard-rspec'

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.md"]
  s.require_paths = ['lib']

end
