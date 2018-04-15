# frozen_string_literal: true

# Utility methods to manage the breadcrumb history
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

  def pop_detour(session)
    detours = session[:detours]
    return nil unless detours
    detour = detours.pop
    Rails.logger.debug "popped detour: #{detour.inspect} #{session[:detours].size} more"
    reset_workflow(session) if detours.empty?
    detour
  end

  def reset_workflow(session)
    session.delete(:detours)
  end
end
