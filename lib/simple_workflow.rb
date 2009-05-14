$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RubyShoppe
  VERSION = '0.0.1'
end

require 'simple_workflow/simple_workflow_helper'
