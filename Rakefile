require 'rake/clean'
require 'rake/testtask'
require 'yard'
require 'bundler/gem_tasks'

task :default => :test

Rake::TestTask.new do |t|
  t.options = '--verbose'
end
YARD::Rake::YardocTask.new
