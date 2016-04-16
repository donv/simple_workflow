require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start { coverage_dir File.expand_path('../coverage', File.dirname(__FILE__)) }
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!
require 'rails'
require 'simple_workflow'

if Gem::Requirement.new('~>4.2') =~ Gem::Version.new(Rails.version)
  ActiveSupport::TestCase.test_order = :random
end

FileUtils.mkdir_p File.expand_path '../log', __dir__
