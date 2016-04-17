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
    (50..99).each do |i|
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

  def test_huge_detour_over_4k
    query = "/orders/TeYphD2wcYyBDFaKTnmAog/edit?detour%5Baction%5D=index&detour%5Bcommit%5D=Search&detour%5Bcontroller%5D=order_drilldown&detour%5Bdrilldown_search%5D%5Bdimensions%5D%5B%5D=arrival&detour%5Bdrilldown_search%5D%5Bdimensions%5D%5B%5D=delay&detour%5Bdrilldown_search%5D%5Bdisplay_type%5D=NONE&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bactual_time%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bcomments%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdelay%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdescription%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdirection%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bdrop_off_stand%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bestimated%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bfirst_vehicle%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bofb%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bonb%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Boperation%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bpick_up%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bpick_up_stand%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bplanned%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bprobable%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bscheduled%5D=1&detour%5Bdrilldown_search%5D%5Bfields%5D%5Bsta%5D=0&detour%5Bdrilldown_search%5D%5Bfields%5D%5Btime%5D=0&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Barrival%5D%5B%5D=Arrival&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Barrival%5D%5B%5D=Departure&detour%5Bdrilldown_search%5D%5Bfilter%5D%5Bcalendar_date%5D%5B%5D=2016-03-01&detour%5Bdrilldown_search%5D%5Blist%5D=1&detour%5Bdrilldown_search%5D%5Blist_change_times%5D=0&detour%5Bdrilldown_search%5D%5Border_by_value%5D=0&detour%5Bdrilldown_search%5D%5Bpercent%5D=1&detour%5Bdrilldown_search%5D%5Bselect_value%5D=COUNT&detour%5Bdrilldown_search%5D%5Btitle%5D=OSL+Daily+Delay+Report+2016-04-16#{'+etc' * 200}&detour%5Butf8%5D=%E2%9C%93"
    env = env_for(query)

    status, headers, response = @stack.call env

    assert_equal 200, status
    assert_equal(env, headers)
    assert_equal 'app response', response
    assert_equal(%w(session_id), headers['rack.session'].to_hash.keys)
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
