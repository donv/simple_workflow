module SimpleWorkflow::Helper
  def image_button_to(image_source, title, options, html_options = {})
    image_submit_tag image_source, {:class   => 'image-submit', :alt => title, :title => title,
                                    :id      => "#{title}_#{options[:id]}", :name => title,
                                    :onclick => "form.action='#{url_for(options)}'"}.update(html_options)
  end

  def detour_to(title, options = nil, html_options = nil, &block)
    if block
      html_options     = options
      options          = title
      link_with_detour = link_to(with_detour(options), html_options, &block)
    else
      link_with_detour = link_to(title, with_detour(options), html_options)
    end
    if link_with_detour.size > 4096 # URL maximum size overflow
      if block
        link_with_detour = link_to(options, html_options, &block)
      else
        link_with_detour = link_to(title, options, html_options)
      end
    end
    link_with_detour
  end

  # Takes a link destination and augments it with the current page as origin.
  # If the optional second argument is given, it is used as the origin.
  # If the given origin is only an anchor, it is added to the current page.
  def with_detour(options, origin = origin_options)
    origin.update(origin_options) if origin.keys == [:anchor]
    url = url_for(options)
    url + (url =~ /\?/ ? '&' : '?') + origin.to_param('detour')
  end

  def origin_options
    params.reject { |k, v| [:detour, :return_from_detour].include? k.to_sym }
  end

  def image_detour_to(image_source, title, url_options, image_options = nil, link_options = nil)
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    detour_to image_tag(image_source, image_options), url_options, link_options
  end

  def image_link_to(image_source, title, url_options, image_options = nil, link_options = nil)
    if link_options == true
      link_options = {:method => :post}
    elsif link_options == false
      link_options = nil
    end
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    link_to image_tag(image_source, image_options), url_options, link_options
  end

  def image_link_to_remote(image_source, title, link_options, image_options = nil, html_options = {})
    if html_options == true
      html_options = {:method => :post}
    elsif html_options == false
      html_options = {}
    end
    image_options ||= {:class => 'image-submit'}
    image_options.update :alt => title, :title => title
    link_to image_tag(image_source, image_options), link_options, html_options.merge(:remote => true)
  end

  def detour?
    not session[:detours].nil?
  end

  def back_or_link_to(title, options = nil, html_options = nil)
    if session[:detours]
      options      = {:return_from_detour => true}.update(session[:detours].last)
      options['id'] ||= nil
      logger.debug "linked return from detour: #{options.inspect}"
    end
    link_to(title, options, html_options) if options
  end

end
