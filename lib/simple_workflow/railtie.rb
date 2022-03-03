# frozen_string_literal: true

module SimpleWorkflow
  # Railtie to activate the middleware.
  class Railtie < Rails::Railtie
    initializer 'SimpleWorkflow.configure_rails_initialization' do |app|
      app.middleware.insert_before ActionDispatch::Flash, SimpleWorkflow::Middleware

      # Make workflow test utility methods available in views
      ActionView::Base.include SimpleWorkflow::Helper

      # Make workflow test utility methods available in controllers
      ActionController::Base.include SimpleWorkflow::Helper
      ActionController::Base.include SimpleWorkflow::Controller

      # Make workflow test utility methods available in ActiveSupport test cases
      ActiveSupport::TestCase.include SimpleWorkflow::TestHelper
    end
  end
end
