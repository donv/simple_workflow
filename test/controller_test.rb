require_relative 'test_helper'
require 'rails'

class ControllerTest < MiniTest::Test
  include SimpleWorkflow::Controller
  attr_accessor :cookies, :logger, :session

  def setup
    options = {encrypted_cookie_salt: 'salt1', encrypted_signed_cookie_salt: 'salt2', secret_key_base: 'secret_key_base'}
    @cookies = ActionDispatch::Cookies::CookieJar.new(ActiveSupport::KeyGenerator.new('secret'), nil, false, options)
    @logger = Rails.logger
    @session = {}
    Rails.app_class = TestApp
  end

  def test_store_detour
    location = {controller: :mycontroller, action: :myaction}

    store_detour(location)

    assert_equal({detours: [location]}, session)
  end

end

class TestApp < Rails::Application
  config.logger = Logger.new($stdout)
  Rails.logger = config.logger
end
