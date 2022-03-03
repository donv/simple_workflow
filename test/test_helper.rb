# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start do
  coverage_dir File.expand_path('../coverage', File.dirname(__FILE__))
  minimum_coverage 75
end
require 'minitest/autorun'
require 'rails'
require 'simple_workflow'

FileUtils.mkdir_p File.expand_path '../log', __dir__

module SimpleWorkflow::Controller
  def self.action_encoding_template(_action)
    false
  end
end
