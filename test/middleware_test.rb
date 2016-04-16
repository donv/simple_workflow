require_relative 'test_helper'
require 'simple_workflow/middleware'
require_relative 'test_app'

class MiddlewareTest < MiniTest::Test
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
    assert_equal(env, headers)
    assert_equal 'app response', response
    assert_equal([], headers['rack.session'].to_hash.keys)
    assert_equal(nil, headers['rack.session'].to_hash['detours'])
  end

  def test_detour
    env = env_for('/?detour[controller]=test')

    status, headers, response = @stack.call env

    assert_equal 200, status
    assert_equal(env, headers)
    assert_equal 'app response', response
    assert_equal(%w(session_id detours), headers['rack.session'].to_hash.keys)
    assert_equal([{'controller' => 'test'}], headers['rack.session'].to_hash['detours'])
  end

  def test_detour_cleanup
    _, env, _ = @stack.call env_for('/?detour[controller]=test_first')
    100.times do |i|
      _, env, _ = @stack.call env_for("/?detour[controller]=test_#{i}",
          'rack.session' => env['rack.session'],
          'rack.session.options' => env['rack.session.options']
      )
    end
    status, env, response = @stack.call env_for('/?detour[controller]=test_last',
        'rack.session' => env['rack.session'],
        'rack.session.options' => env['rack.session.options']
    )

    assert_equal 200, status
    assert_equal 'app response', response
    assert_equal(%w(session_id detours), env['rack.session'].to_hash.keys)

    assert_equal([{'controller' => 'test_57'}, {'controller' => 'test_58'}, {'controller' => 'test_59'}, {'controller' => 'test_60'}, {'controller' => 'test_61'}, {'controller' => 'test_62'}, {'controller' => 'test_63'}, {'controller' => 'test_64'}, {'controller' => 'test_65'}, {'controller' => 'test_66'}, {'controller' => 'test_67'}, {'controller' => 'test_68'}, {'controller' => 'test_69'}, {'controller' => 'test_70'}, {'controller' => 'test_71'}, {'controller' => 'test_72'}, {'controller' => 'test_73'}, {'controller' => 'test_74'}, {'controller' => 'test_75'}, {'controller' => 'test_76'}, {'controller' => 'test_77'}, {'controller' => 'test_78'}, {'controller' => 'test_79'}, {'controller' => 'test_80'}, {'controller' => 'test_81'}, {'controller' => 'test_82'}, {'controller' => 'test_83'}, {'controller' => 'test_84'}, {'controller' => 'test_85'}, {'controller' => 'test_86'}, {'controller' => 'test_87'}, {'controller' => 'test_88'}, {'controller' => 'test_89'}, {'controller' => "test_90"}, {"controller" => "test_91"}, {"controller" => "test_92"}, {"controller" => "test_93"}, {"controller" => "test_94"}, {"controller" => "test_95"}, {"controller" => "test_96"}, {"controller" => "test_97"}, {"controller" => "test_98"}, {"controller" => "test_99"}, {"controller" => "test_last"}],
        env['rack.session'].to_hash['detours'])
  end

  private

  def env_for(url, opts={})
    default_opts = {
        ActionDispatch::Cookies::COOKIES_SERIALIZER => :json,
        ActionDispatch::Cookies::GENERATOR_KEY => ActiveSupport::KeyGenerator.new('secret'),
        ActionDispatch::Cookies::SECRET_KEY_BASE => 'secret',
        # ActionDispatch::Cookies::SECRET_TOKEN => 'secret',
    }
    Rack::MockRequest.env_for(url, default_opts.update(opts))
  end

end
