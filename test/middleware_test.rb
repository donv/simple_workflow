# frozen_string_literal: true

require_relative 'test_helper'
require 'simple_workflow/middleware'
require_relative 'test_app'

class MiddlewareTest < Minitest::Test
  def setup
    @app = TestApp.instance
    # @app = ->(env) { [200, env, 'app response'] }
    @stack = Rack::Builder.new @app do
      use ActionDispatch::Cookies
      use ActionDispatch::Session::CookieStore
      use SimpleWorkflow::Middleware
      use ActionDispatch::Flash
    end
    @request = Rack::MockRequest.new(@stack)
  end

  def test_get_without_detour
    env = env_for('/')

    status, headers, response = @stack.call env

    assert_equal 200, status
    assert_equal ['app response'], response
    assert_equal [], headers['rack.session'].to_hash.keys
    assert_nil headers['rack.session'].to_hash['detours']
  end

  def test_detour
    env = env_for('/?detour[controller]=test')

    status, headers, body = @stack.call(env)

    assert_equal 200, status
    assert_equal ['app response'], body
    assert_equal(%w[session_id detours], headers['rack.session'].to_hash.keys)
    assert_equal([{ 'controller' => 'test' }], headers['rack.session'].to_hash['detours'])
  end

  def test_detour_cleanup
    _, env, = @stack.call env_for('/?detour[controller]=test_first')
    (50..99).each do |i|
      next_env = env_for("/?detour[controller]=test_#{i}",
                         'rack.session' => env['rack.session'],
                         'rack.session.options' => env['rack.session.options'])
      _, env, = @stack.call next_env
    end
    last_env = env_for('/?detour[controller]=test_last',
                       'rack.session' => env['rack.session'],
                       'rack.session.options' => env['rack.session.options'])
    status, env, response = @stack.call last_env

    assert_equal 200, status
    assert_equal ['app response'], response
    assert_equal(%w[session_id detours], env['rack.session'].to_hash.keys)

    assert_equal(((57..99).to_a + [:last]).map { |i| { 'controller' => "test_#{i}" } },
                 env['rack.session'].to_hash['detours'])
  end

  def test_huge_detour_over_4k
    # rubocop:disable Layout/LineLength
    query = "/orders/TeYphD2wcYyBDFaKTnmAog/edit?detour%5Baction%5D=index&detour%5Bcommit%5D=Search&detour%5Bcontroller%5D=order_drilldown&detour%5Bdrilldown_search%5D%5Bdimensions%5D%5B%5D=arrival&detour%5Bdrilldown_search%5D%5Bdimensions%5D%5B%5D=delay&detour%5Bdrilldown_search%5D%5Bdisplay_type%5D=NONE&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bactual_time%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bcomments%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdelay%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdescription%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdirection%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdrop_off_stand%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bestimated%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bfirst_vehicle%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bofb%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bonb%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Boperation%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bpick_up%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bpick_up_stand%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bplanned%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bprobable%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bscheduled%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bsta%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Btime%5D=0&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Barrival%5D%5B%5D=Arrival&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Barrival%5D%5B%5D=Departure&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Bcalendar_date%5D%5B%5D=2016-03-01&detour%5Bdrilldown_search%5D%5Blist%5D=1&detour%5Bdrilldown_search%5D%5Blist_change_times%5D=0&detour%5Bdrilldown_search%5D%5Border_by_value%5D=0&detour%5Bdrilldown_search%5D%5Bpercent%5D=1&detour%5Bdrilldown_search%5D%5Bselect_value%5D=COUNT&detour%5Bdrilldown_search%5D%5Btitle%5D=OSL+Daily+Delay+Report+2016-04-16#{'+etc' * 200}&detour%5Butf8%5D=%E2%9C%93"
    # rubocop:enable Layout/LineLength
    env = env_for(query)

    status, headers, response = @stack.call env

    assert_equal 200, status
    assert_equal ['app response'], response
    assert_equal(%w[session_id], headers['rack.session'].to_hash.keys)
  end

  def test_return_from_detour
    _, headers1, = @stack.call env_for('/?detour[controller]=test_first')
    env = env_for('/?return_from_detour=true',
                  'rack.session' => headers1['rack.session'],
                  'rack.session.options' => headers1['rack.session.options'])
    status, headers, response = @stack.call env

    assert_equal 200, status
    assert_match(%r{_session_id=\w+--\w+; path=/; httponly}, headers['set-cookie'])
    assert_equal ['app response'], response
    assert_equal ['session_id'], headers['rack.session'].to_hash.keys
    assert_nil headers['rack.session'].to_hash['detours']
  end

  private

  def env_for(url, opts = {})
    default_opts = {
      ActionDispatch::Cookies::COOKIES_ROTATIONS => ActiveSupport::Messages::RotationConfiguration.new,
      ActionDispatch::Cookies::COOKIES_SERIALIZER => :json,
      ActionDispatch::Cookies::ENCRYPTED_COOKIE_SALT => 'salt',
      ActionDispatch::Cookies::ENCRYPTED_SIGNED_COOKIE_SALT => 'signed_salt',
      ActionDispatch::Cookies::GENERATOR_KEY => ActiveSupport::KeyGenerator.new('secret'),
      ActionDispatch::Cookies::SECRET_KEY_BASE => 'secret',
    }
    Rack::MockRequest.env_for(url, default_opts.update(opts))
  end
end
