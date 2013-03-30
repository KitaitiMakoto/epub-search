# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epub/search/version'

Gem::Specification.new do |gem|
  gem.name          = "epub-search"
  gem.version       = EPUB::Search::VERSION
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = ["KitaitiMakoto@gmail.com"]
  gem.description   = %q{Provides tool and library of full text search for EPUB books}
  gem.summary       = %q{Full text search for EPUB books}
  # gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc      = 'yard'

  gem.add_runtime_dependency 'epub-parser'
  gem.add_runtime_dependency 'rroonga'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'rb-inotify'
  gem.add_runtime_dependency 'listen'
  gem.add_runtime_dependency 'highline'
  gem.add_runtime_dependency 'notify'
  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'tilt'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'test-unit-notify'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
end
