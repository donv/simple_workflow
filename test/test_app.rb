# frozen_string_literal: true

require 'rails'

class TestApp < Rails::Application
  config.action_dispatch.cookies_serializer = :json
  config.action_dispatch.key_generator = ActiveSupport::KeyGenerator.new('secret')
  config.logger = Logger.new(File.expand_path('../log/test.log', __dir__))
  config.secret_key_base = 'secret key base'

  Rails.logger = config.logger

  def call(env)
    [200, env, 'app response']
  end
end
