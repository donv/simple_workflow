require 'rake'
require 'lib/simple_workflow/version'

Gem::Specification.new do |s|
  s.name = %q{simple_workflow}
  s.version = SimpleWorkflow::VERSION
  s.date = Date.today.strftime '%Y-%m-%d'
  s.authors = ['Uwe Kubosch']
  s.email = %q{uwe@kubosch.no}
  s.summary = %q{Add simple "detour" workflow to Ruby On Rails.}
  s.homepage = %q{https://github.com/donv/simple_workflow}
  s.description = %Q{Expands Ruby On Rails to allow simple detour workflows.}
  s.rubyforge_project = "ruby-shoppe"
  s.files = FileList['[A-Z]*', 'lib/**/*', 'test/**/*'].to_a
  s.add_dependency('rails','>= 2.3.2')
end
