require 'simple_workflow/detour'

class SimpleWorkflow::Middleware
  include SimpleWorkflow::Detour

  def initialize(app)
    @app = app
    @simple_workflow_encryptor = nil
  end

  def call(env)
    store_detour_from_params(env)
    status, headers, response = @app.call(env)
    remove_old_detours(env)
    [status, headers, response]
  end

  private

  def request(env)
    ActionDispatch::Request.new(env)
  end

  def cookie_jar(env)
    request(env).cookie_jar.signed_or_encrypted
  end

  def params(env)
    request(env).params
  end

  def cookies(env)
    request(env).cookies
  end

  def session(env)
    env['rack.session']
  end

  def remove_old_detours(env)
    if (cookie_store = session(env).instance_variable_get('@by'))
        .is_a? ActionDispatch::Session::CookieStore
      ss = ws = nil
      session = session(env)
      loop do
        # env[ActionDispatch::Cookies::COOKIES_SERIALIZER]
        ser_val = cookie_jar(env).send(:serialize, nil, session.to_hash)
        ss = encryptor(env).encrypt_and_sign(ser_val).size
        wf_ser_val = cookie_jar(env).send(:serialize, nil, session[:detours])
        ws = encryptor(env).encrypt_and_sign(wf_ser_val).size
        break unless ws >= 2048 || (ss >= 3072 && session[:detours] && session[:detours].size > 0)
        Rails.logger.warn "Workflow too large (#{ws}/#{ss}).  Dropping oldest detour."
        session[:detours].shift
        reset_workflow(session) if session[:detours].empty?
      end
      Rails.logger.debug "session: #{ss} bytes, workflow(#{session[:detours].try(:size) || 0}): #{ws} bytes"
    end
  end

  def encryptor(env)
    return @simple_workflow_encryptor if @simple_workflow_encryptor
    @simple_workflow_encryptor = cookie_jar(env).instance_variable_get(:@encryptor)
    return @simple_workflow_encryptor if @simple_workflow_encryptor
    secret_key_base = Rails.application.config.secret_key_base ||
        Rails.application.config.secret_token ||
        SecureRandom.hex(64)
    key_generator = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)
    key_generator = ActiveSupport::CachingKeyGenerator.new(key_generator)
    secret = key_generator.generate_key('encrypted cookie')
    sign_secret = key_generator.generate_key('signed encrypted cookie')
    @simple_workflow_encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret)
  end

  def store_detour_from_params(env)
    if params(env)[:detour]
      store_detour_in_session(session(env), params(env)[:detour])
    end
    if params(env)[:return_from_detour] && session(env)[:detours]
      pop_detour(session(env))
    end
  end

end
