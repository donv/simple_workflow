module SimpleWorkflow
  class Railtie < Rails::Railtie
    initializer 'SimpleWorkflow.configure_rails_initialization' do |app|
      app.middleware.insert_before ActionDispatch::Flash,
          SimpleWorkflow::Middleware
    end
  end
end
