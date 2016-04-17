require 'simple_workflow/detour'

module SimpleWorkflow::Controller
  include SimpleWorkflow::Detour

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
    store_detour_in_session(session, options)
  end

  def store_detour_from_params
  end
  deprecate :store_detour_from_params,
      deprecator: ActiveSupport::Deprecation.new('1.2', 'SimpleWorkflow') # TODO(uwe)

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
    reset_workflow(session) if detours.empty?
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
