module SimpleWorkflow::Detour
  def store_detour_in_session(session, options)
    if session[:detours] && session[:detours].last == options
      Rails.logger.try(:debug, "Ignored duplicate detour: #{options.inspect}")
      return
    end
    session[:detours] ||= []
    session[:detours] << options
    Rails.logger.try(:debug, "Added detour (#{session[:detours].try(:size) || 0}): #{options.inspect}")
  end
end
