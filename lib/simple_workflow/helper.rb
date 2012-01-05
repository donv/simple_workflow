module SimpleWorkflow::Helper
  def image_button_to(image_source, title, options, html_options = {})
    image_submit_tag image_source, {:class   => 'image-submit', :alt => title, :title => title,
                                    :id      => "#{title}_#{options[:id]}", :name => title,
                                    :onclick => "form.action='#{url_for(options)}'"}.update(html_options)
  end

  def detour_to(title, options, html_options = nil)
    link_to title, with_detour(options), html_options
  end

  def with_detour(options)
    detour_options = {:detour => params.reject { |k, v| [:detour, :return_from_detour].include? k.to_sym }}
    if options.is_a? String
      return options + (options =~ /\?/ ? '&' : '?') + detour_options[:detour].map{|k,v| "detour[#{k}]=#{v}"}.join('&')
    else
      detour_options.merge(options)
      if options[:layout] == false
        if params[:action] !~ /_no_layout$/
          detour_options[:detour].update({:action => params[:action] + '_no_layout'})
        end
      elsif params[:action] =~ /_no_layout$/
        detour_options[:detour].update({:action => params[:action][0..-11]})
      end
      detour_options
    end
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

  def image_link_to_remote(image_source, title, link_options, image_options = nil, post = false)
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    with_params = link_options.delete(:with)
    link_to_remote image_tag(image_source, image_options), :url => link_options, :with => with_params, :html => post ? {:method => :post} : {}
  end

  def detour?
    not session[:detours].nil?
  end

  def back_or_link_to(title, options = nil)
    if session[:detours]
      options = {:return_from_detour => true}.update(session[:detours].last)
      logger.debug "linked return from detour: #{options}"
    end
    link_to(title, options) if options
  end

end
