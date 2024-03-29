# -*- encoding: utf-8 -*-
require File.expand_path('../lib/html_tables/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Fábio David Batista']
  gem.email         = ['fabio.batista@consyste.com.br']
  gem.description   = %q{Simple DSL for HTML data tables}
  gem.summary       = %q{This gem was extracted from some projects on my company. Everyone is welcome to use and improve upon.}
  gem.homepage      = 'https://consyste.com.br/'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'html_tables'
  gem.require_paths = ['lib']
  gem.version       = HtmlTables::VERSION

  gem.add_dependency 'i18n'
  gem.add_dependency 'actionpack'
  gem.add_dependency 'railties'

  gem.add_development_dependency 'rspec', '~> 3.12'
  gem.add_development_dependency 'rspec-html-matchers'
  gem.add_development_dependency 'symbolize'
  gem.add_development_dependency 'enumerize'
  gem.add_development_dependency 'activerecord', '~> 4.2.11'
  gem.add_development_dependency 'sqlite3', '~> 1.3.6'
end
