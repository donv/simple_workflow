$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module SimpleWorkflow
  VERSION = '0.0.2'
end

require 'simple_workflow/simple_workflow_helper'
