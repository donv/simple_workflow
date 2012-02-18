$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'simple_workflow/version'
require 'simple_workflow/helper'
require 'simple_workflow/controller'
require 'action_controller/base'

module ApplicationHelper
  include SimpleWorkflow::Helper
end

class ActionController::Base
  include SimpleWorkflow::Helper
  include SimpleWorkflow::Controller
  before_filter :store_detour_from_params
end
