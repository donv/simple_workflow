# frozen_string_literal: true

# Utility methods to manage the breadcrumb history
module SimpleWorkflow::Detour
  def store_detour_in_session(session, options)
    if session[:detours]
      if session[:detours].last == options
        Rails.logger.try(:debug, "Ignored duplicate detour: #{options.inspect}")
        return
      end
      if session[:detours].delete(options)
        Rails.logger.try(:debug, "Deleted duplicate detour: #{options.inspect}")
      end
    else
      session[:detours] = []
    end
    session[:detours] << options
    Rails.logger.try(:debug, "Added detour (#{session[:detours].try(:size) || 0}): #{options.inspect}")
  end

  def pop_detour(session, origin_options = nil)
    detours = session[:detours]
    return nil unless detours

    detour = detours.delete(origin_options) || detours.pop
    Rails.logger.debug "popped detour: #{detour.inspect} #{session[:detours].size} more"
    reset_workflow(session) if detours.empty?
    detour
  end

  def reset_workflow(session)
    session.delete(:detours)
  end
end
