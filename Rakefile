# frozen_string_literal: true

require 'bundler/gem_tasks'

task default: :test

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose    = true
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new
Rake::Task[:test].enhance ['rubocop:auto_correct']
