# frozen_string_literal: true

require 'simple_workflow/detour'
require 'active_support/core_ext/string/strip'

# Rack middleware to detect and store detours and manage returns from detours.
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
    return unless session(env).instance_variable_get('@by').is_a?(ActionDispatch::Session::CookieStore)

    session_size = workflow_size = nil
    session = session(env)
    cookie_jar = cookie_jar(env)
    encryptor = encryptor(env)
    loop do
      ser_val = serialize_session(cookie_jar, session.to_hash)
      session_size = encryptor.encrypt_and_sign(ser_val).size
      wf_ser_val = serialize_session(cookie_jar, session[:detours])
      workflow_size = encryptor.encrypt_and_sign(wf_ser_val).size
      break unless workflow_size >= 2048 ||
          (session_size >= 3072 && session[:detours] && !session[:detours].empty?)

      Rails.logger.warn("Workflow too large (#{workflow_size}/#{session_size}).  Dropping oldest detour.")
      session[:detours].shift
      reset_workflow(session) if session[:detours].empty?
    end
    Rails.logger.debug <<-MSG.strip_heredoc
      session: #{session_size} bytes, workflow(#{session[:detours].try(:size) || 0}): #{workflow_size} bytes
    MSG
    return unless session_size > 4096

    Rails.logger.warn <<-MSG.strip_heredoc
      simple_workflow: session exceeds cookie size limit: #{session_size} bytes.  Workflow empty!  Not My Fault!
    MSG
    Rails.logger.warn "simple_workflow: session: #{session.to_hash}"
    remove_discarded_flashes(session)
  end

  def remove_discarded_flashes(session)
    return unless (old_flashes = session[:flash] && session[:flash]['discard'])

    Rails.logger.warn <<-MSG.strip_heredoc
      simple_workflow: found discarded flash entries: #{old_flashes}.  Deleting them.
    MSG
    session[:flash]['flashes'] = session[:flash]['flashes'].except(*old_flashes)
    Rails.logger.warn "simple_workflow: session: #{session.to_hash}"
  end

  if ActionPack::VERSION::MAJOR >= 5
    def serialize_session(cookie_jar, session)
      cookie_jar.send(:serialize, session)
    end
  else # Rails 4.x
    def serialize_session(cookie_jar, session)
      cookie_jar.send(:serialize, nil, session)
    end
  end

  def encryptor(env)
    return @simple_workflow_encryptor if @simple_workflow_encryptor

    @simple_workflow_encryptor = cookie_jar(env).instance_variable_get(:@encryptor)
    return @simple_workflow_encryptor if @simple_workflow_encryptor

    Rails.logger.warn 'simple_workflow: Could not get encryptor from the cookie jar'
    secret_key_base = Rails.application.config.secret_key_base || Rails.application.config.secret_token ||
        SecureRandom.hex(64)
    key_generator = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)
    key_generator = ActiveSupport::CachingKeyGenerator.new(key_generator)
    secret = key_generator.generate_key('encrypted cookie')
    sign_secret = key_generator.generate_key('signed encrypted cookie')
    @simple_workflow_encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret)
  end

  def store_detour_from_params(env)
    store_detour_in_session(session(env), params(env)[:detour]) if params(env)[:detour]
    return unless params(env)[:return_from_detour] && session(env)[:detours]

    params_hash = params(env).to_h.reject { |k, _v| %i[detour return_from_detour].include? k.to_sym }
    pop_detour(session(env), params_hash)
  end
end
