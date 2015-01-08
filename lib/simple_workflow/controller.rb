module SimpleWorkflow::Controller
  # Like ActionController::Base#redirect_to, but stores the location we come from, enabling returning here later.
  def detour_to(options)
    store_detour(params)
    redirect_to(options)
  end

  def rjs_detour_to(options)
    store_detour(params, request.post?)
    rjs_redirect_to(options)
  end

  def rjs_redirect_to(options)
    @options = options
    render :template => 'redirect', :layout => false, :formats => :js
  end

  def store_detour(options, post = false)
    options = options.dup.permit!.to_h if options.is_a?(ActionController::Parameters)
    options[:request_method] = :post if post
    if session[:detours] && session[:detours].last == options
      logger.debug "Ignored duplicate detour: #{options.inspect}"
      return
    end
    session[:detours] ||= []
    session[:detours] << options

    if Rails.application.config.session_store == ActionDispatch::Session::CookieStore
      encryptor = cookies.signed_or_encrypted.instance_variable_get(:@encryptor)
      ss = ws = nil
      loop do
        ser_val = cookies.signed_or_encrypted.send(:serialize, nil, session.to_hash)
        new_value = encryptor.encrypt_and_sign(ser_val)
        ss = new_value.size
        wf_ser_val = cookies.signed_or_encrypted.send(:serialize, nil, session[:detours])
        wf_crypt_val = encryptor.encrypt_and_sign(wf_ser_val)
        ws = wf_crypt_val.size
        break unless ws >= 2048 || (ss >= 3072 && session[:detours] && session[:detours].size > 0)
        logger.warn "Workflow too large (#{ws}).  Dropping oldest detour."
        session[:detours].shift
        reset_workflow if session[:detours].empty?
      end
      logger.debug "session: #{ss} bytes, workflow(#{session[:detours].try(:size) || 0}): #{ws} bytes"
    end

    logger.debug "Added detour (#{session[:detours].try(:size) || 0}): #{options.inspect}"
  end

  def store_detour_from_params
    if params[:detour]
      store_detour(params[:detour])
    end
    if params[:return_from_detour] && session[:detours]
      pop_detour
    end
  end

  def back(response_status_and_flash)
    return false if session[:detours].nil?
    detour = pop_detour
    post = detour.delete(:request_method) == :post
    if post
      set_flash(response_status_and_flash)
      redirect_to_post(detour)
    else
      redirect_to detour, response_status_and_flash
    end
    true
  end

  def back_or_redirect_to(options = {}, response_status_and_flash = {})
    back(response_status_and_flash) or redirect_to(options, response_status_and_flash)
  end

  def set_flash(response_status_and_flash)
    if (alert = response_status_and_flash.delete(:alert))
      flash[:alert] = alert
    end

    if (notice = response_status_and_flash.delete(:notice))
      flash[:notice] = notice
    end

    if (other_flashes = response_status_and_flash.delete(:flash))
      flash.update(other_flashes)
    end
  end
  private :set_flash

  def pop_detour
    detours = session[:detours]
    return nil unless detours
    detour = detours.pop
    logger.debug "popped detour: #{detour.inspect} #{session[:detours].size} more"
    reset_workflow if detours.empty?
    detour
  end

  def reset_workflow
    session.delete(:detours)
  end

  def redirect_to_post(options)
    url = url_for options
    render :text => <<EOF, :layout => false
<html>
  <body onload="document.getElementById('form').submit()">
    <form id="form" action="#{url}" method="POST">
    </form>
  </body>
</html>
EOF
  end

end
