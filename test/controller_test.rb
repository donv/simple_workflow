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
    @bad_route = false
    # TODO(uwe):  Remove when we stop testing Rails 4.1
    if Rails.version !~ /^4\.1\./
      Rails.app_class = TestApp
    end
    # ODOT
  end

  def test_store_detour
    location = {controller: :mycontroller, action: :myaction}

    store_detour(location)

    assert_equal({detours: [location]}, session)
  end

  # TODO(uwe): Remove.  The method does nothing.  Just a stub for compatability.
  def test_deprecated_store_detour_from_params
    store_detour_from_params
    assert_equal({}, session)
  end
  # ODOT

  def test_back
    store_detour({controller: :mycontroller, action: :myaction})
    back({})
    assert_equal({}, session)
  end

  def test_back_with_invalid_detour # not route
    store_detour({controller: :mycontroller, action: :missing_in_action})
    @bad_route = true
    back({})
    assert_equal({}, session)
  end

  private

  def redirect_to(_path, _response_status_and_flash)
    raise 'Bad route' if @bad_route
  end
end

class TestApp < Rails::Application
  config.logger = Logger.new($stdout)
  Rails.logger = config.logger
end
