require 'rubygems'
require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'nationbuilder-rb'
  gem.homepage = 'http://github.com/3dna/nationbuilder-rb'
  gem.license = 'MIT'
  gem.summary = 'A Ruby client to the NationBuilder API'
  gem.description = 'A Ruby client to the NationBuilder API'
  gem.email = 'david@nationbuilder.com'
  gem.authors = ['David Huie']
end

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].execute
end

task default: :spec

desc 'Display all known NationBuilder API endpoints, methods, and parameters'
task :describe_nb_api do
  require 'nationbuilder'
  NationBuilder.print_description
end
