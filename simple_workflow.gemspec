# frozen_string_literal: true

require 'rake'
require './lib/simple_workflow/version'
require 'date'

Gem::Specification.new do |s|
  s.name = 'simple_workflow'
  s.version = SimpleWorkflow::VERSION
  s.authors = ['Uwe Kubosch']
  s.email = 'uwe@kubosch.no'
  s.summary = 'Add simple breadcrumbs "detour" workflow to Ruby On Rails.'
  s.homepage = 'https://github.com/donv/simple_workflow'
  s.description = 'Expands Ruby on Rails to allow simple breadcrumb detour workflows.'
  s.required_ruby_version = '>= 2.5', '<4'
  s.licenses = %w[MIT]
  s.files = FileList['[A-Z]*', 'lib/**/*', 'test/**/*'].to_a

  s.add_runtime_dependency('rails', '>=6.2', '<8')

  s.add_development_dependency('rubocop', '~>1.0')
  s.add_development_dependency('rubocop-performance', '~>1.5')
  s.add_development_dependency('rubocop-rails', '~>2.4')
  s.add_development_dependency('simplecov', '~>0.9')
  s.metadata['rubygems_mfa_required'] = 'false'
end
