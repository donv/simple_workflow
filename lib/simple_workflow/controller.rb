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
    render :template => 'redirect', :layout => false
  end

  def store_detour(options, post = false)
    options[:request_method] = :post if post
    if session[:detours] && session[:detours].last == options
      logger.debug "duplicate detour: #{options.inspect}"
      return
    end
    logger.debug "adding detour: #{options.inspect}"
    session[:detours] ||= []
    session[:detours] << options
  end

  def store_detour_from_params
    if params[:detour]
      store_detour(params[:detour])
    end
    if params[:return_from_detour] && session[:detours]
      pop_detour
    end
  end

  def back
    return false if session[:detours].nil?
    detour = pop_detour
    post = detour.delete(:request_method) == :post
    if post
      redirect_to_post(detour)
    else
      redirect_to detour
    end
    true
  end

  def back_or_redirect_to(*options)
    back or redirect_to(*options)
  end

  def pop_detour
    detours = session[:detours]
    return nil unless detours
    detour = detours.pop
    logger.debug "popped detour: #{detour.inspect} #{session[:detours].size} more"
    if detours.empty?
      session[:detours] = nil
    end
    detour
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
