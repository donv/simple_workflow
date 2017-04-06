# Utility methods to ease testing.
module SimpleWorkflow::TestHelper
  def add_stored_detour(location = { controller: :bogus, action: :location })
    @request.session[:detours] = [location]
  end
end
