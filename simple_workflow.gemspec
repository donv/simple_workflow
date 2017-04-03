require 'rake'
require './lib/simple_workflow/version'
require 'date'

Gem::Specification.new do |s|
  s.name = 'simple_workflow'
  s.version = SimpleWorkflow::VERSION
  s.date = Date.today.strftime '%Y-%m-%d'
  s.authors = ['Uwe Kubosch']
  s.email = 'uwe@kubosch.no'
  s.summary = 'Add simple breadcrumbs "detour" workflow to Ruby On Rails.'
  s.homepage = 'https://github.com/donv/simple_workflow'
  s.description = 'Expands Ruby On Rails to allow simple breadcrumb detour workflows.'
  s.rubyforge_project = 'donv/simple_workflow'
  s.required_ruby_version = '~> 2.1'
  s.licenses = %w(MIT)
  s.files = FileList['[A-Z]*', 'lib/**/*', 'test/**/*'].to_a
  s.add_runtime_dependency('rails', '>=4', '<5.1')
  s.add_development_dependency('simplecov', '~>0.9')
  s.add_development_dependency('minitest-reporters', '~>1.0')
  s.add_development_dependency('rubocop', '~>0.45')
end
