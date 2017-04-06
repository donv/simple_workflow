unless $LOAD_PATH.include?(File.dirname(__FILE__)) ||
       $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
end

require 'action_controller'

require 'simple_workflow/version'
require 'simple_workflow/helper'
require 'simple_workflow/controller'
require 'simple_workflow/test_helper'
require 'simple_workflow/middleware'
require 'simple_workflow/railtie'

# Make workflow test utility methods available in views
module ApplicationHelper
  include SimpleWorkflow::Helper
end

# Make workflow test utility methods available in controllers
class ActionController::Base
  include SimpleWorkflow::Helper
  include SimpleWorkflow::Controller
end

# Make workflow test utility methods available in ActiveSupport test cases
class ActiveSupport::TestCase
  include SimpleWorkflow::TestHelper
end
