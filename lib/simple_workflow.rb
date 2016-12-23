unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  $:.unshift(File.dirname(__FILE__))
end

require 'action_controller'

require 'simple_workflow/version'
require 'simple_workflow/helper'
require 'simple_workflow/controller'
require 'simple_workflow/test_helper'
require 'simple_workflow/middleware'
require 'simple_workflow/railtie'

module ApplicationHelper
  include SimpleWorkflow::Helper
end

class ActionController::Base
  include SimpleWorkflow::Helper
  include SimpleWorkflow::Controller
end

class ActiveSupport::TestCase
  include SimpleWorkflow::TestHelper
end
