# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epub/search/version'

Gem::Specification.new do |gem|
  gem.name          = "epub-search"
  gem.version       = EPUB::Search::VERSION
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = ["KitaitiMakoto@gmail.com"]
  gem.description   = %q{Provides tool and library of full text search for EPUB files}
  gem.summary       = %q{Full text search for EPUB}
  # gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'epub-parser'
  gem.add_runtime_dependency 'rroonga'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'listen'
end
