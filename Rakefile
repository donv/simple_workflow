require 'rake'
require 'rake/clean'
require 'rake/testtask'
require File.dirname(__FILE__) + '/lib/simple_workflow/version'

GEM_FILE      = "simple_workflow-#{SimpleWorkflow::VERSION}.gem"
GEM_SPEC_FILE = 'simple_workflow.gemspec'

CLEAN.include('simple_workflow-*.gem', 'tmp')

task :default => :gem

desc 'Generate a gem'
task :gem => GEM_FILE

file GEM_FILE => GEM_SPEC_FILE do
  puts "Generating #{GEM_FILE}"
  `gem build #{GEM_SPEC_FILE}`
end

desc 'Push the gem to RubyGems'
task :release => :gem do
  output = `git status --porcelain`
  raise "Workspace not clean!\n#{output}" unless output.empty?
  sh "git tag #{SimpleWorkflow::VERSION}"
  sh 'git push --tags'
  sh "gem push #{GEM_FILE}"
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose    = true
end

