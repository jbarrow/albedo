# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
	gem.name			= "albedo"
	gem.platform	= Gem::Platform::RUBY
	gem.authors		= ["Joseph Barrow"]
	gem.email			= ["joe@floor4.co"]
	gem.summary		= "%q{OAuth 1.0A Parameter Checking}"
	gem.description = "%q{Middleware used to verify parameters and act as security in an OAuth implementation}"

	gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

	gem.add_dependency 'rack', '~> 1.4'
	gem.add_dependency 'simple_oauth'
	gem.add_development_dependency 'rspec', '~> 2.7'
end