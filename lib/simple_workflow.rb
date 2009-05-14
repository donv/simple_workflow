$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RubyShoppe
  VERSION = '0.0.1'
end

module SimpleWorkflowHelper
  def image_button_to(image_source, title, options, html_options = {})
    image_submit_tag image_source, {:class => 'image-submit', :alt => title, :title => title,
        :id => "#{title}_#{options[:id]}", :name => title, 
        :onclick => "form.action='#{url_for(options)}'"}.update(html_options)
  end
  
  def detour_to(title, options, html_options = nil)
    link_to title, with_detour(options), html_options
  end
  
  def with_detour(options)
    detour_options = {:detour => params.reject {|k, v| [:detour, :return_from_detour].include? k.to_sym}}.update(options)
    if options[:layout]== false
      if params[:action] !~ /_no_layout$/
        detour_options[:detour].update({:action => params[:action] + '_no_layout'})
      end
    elsif params[:action] =~ /_no_layout$/
      detour_options[:detour].update({:action => params[:action][0..-11]})
    end
    detour_options
  end
  
  def image_detour_to(image_source, title, url_options, image_options = nil, post = false)
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    detour_to image_tag(image_source, image_options), url_options, post ? {:method => :post} : nil 
  end
  
  def image_link_to(image_source, title, url_options, image_options = nil, post = false)
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    link_to image_tag(image_source, image_options), url_options, post ? {:method => :post} : nil
  end
  
  def image_link_to_remote(image_source, title, url_options, image_options = nil, post = false)
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    link_to_remote image_tag(image_source, image_options), {:url => url_options}, post ? {:method => :post} : nil
  end
  
  def detour?
    not session[:detours].nil?
  end
  
  def back_or_link_to(title, options = nil, html_options = nil)
    if session[:detours]
      options = {:return_from_detour => true}.update(session[:detours].last)
      logger.debug "linked return from detour: #{options}"
    end
    link_to(title, options, html_options) if options
  end
  
end

module SimpleWorkflowController
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
      logger.debug "duplicate detour: #{options}"
      return
    end
    logger.debug "adding detour: #{options}"
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
    return true
  end
  
  def back_or_redirect_to(options)
    back or redirect_to options
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
