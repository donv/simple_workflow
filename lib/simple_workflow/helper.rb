# frozen_string_literal: true

require_relative 'detour'

# View helper methods augmented with breadcrumb management.
module SimpleWorkflow::Helper
  include SimpleWorkflow::Detour

  def image_button_to(image_source, title, options, html_options = {})
    image_submit_tag image_source, {
      class: 'image-submit', alt: title, title: title,
      id: "#{title}_#{options[:id]}", name: title,
      onclick: "form.action='#{url_for(options)}'"
    }.update(html_options)
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
      link_with_detour = if block
                           link_to(options, html_options, &block)
                         else
                           link_to(title, options, html_options)
                         end
    end
    link_with_detour
  end

  # Takes a link destination and augments it with the current page as origin.
  # If the optional second argument is given, it is used as the origin.
  # If the given origin is only an anchor, it is added to the current page.
  def with_detour(options, origin = origin_options)
    if origin.is_a?(String)
      uri = URI(origin)
      origin = Rails.application.routes.recognize_path uri.path
      origin.update anchor: uri.fragment if uri.fragment.present?
      origin.update Rack::Utils.parse_nested_query(uri.query) if uri.query.present?
    end
    origin.update(origin_options) if origin.keys == [:anchor]
    url = url_for(options)
    url + (/\?/.match?(url) ? '&' : '?') + origin.to_h.to_param('detour')
  end

  def origin_options
    params.to_unsafe_h.reject { |k, _v| %i[detour return_from_detour].include? k.to_sym }
  end

  def image_detour_to(image_source, title, url_options, image_options = nil, link_options = nil)
    image_options ||= { class: 'image-submit' }
    image_options.update alt: title, title: title
    detour_to image_tag(image_source, image_options), url_options, link_options
  end

  def image_link_to(image_source, title, url_options, image_options = nil, link_options = nil)
    case link_options
    when true
      link_options = { method: :post }
    when false
      link_options = nil
    end
    image_options ||= { class: 'image-submit' }
    image_options.update alt: title, title: title
    link_to image_tag(image_source, image_options), url_options, link_options
  end

  def image_link_to_remote(image_source, title, link_options, image_options = nil,
      html_options = {})
    case html_options
    when true
      html_options = { method: :post }
    when false
      html_options = {}
    end
    image_options ||= { class: 'image-submit' }
    image_options.update alt: title, title: title
    link_to image_tag(image_source, image_options), link_options, html_options.merge(remote: true)
  end

  def detour?
    !session[:detours].nil?
  end

  def back_or_link_to(title, options = nil, html_options = nil, &block)
    if block
      html_options = options
      options = title
      title = nil
    end
    if session[:detours]
      link_options = { return_from_detour: true }.update(session[:detours].last)

      # FIXME(uwe): Write a test to prove this line is needed.
      link_options['id'] ||= nil
      # EMXIF

      logger.debug "linked return from detour: #{link_options.inspect}"
    else
      link_options = options
    end

    if link_options
      if block
        link_to(link_options, html_options, &block)
      else
        link_to(title, link_options, html_options)
      end
    end
  rescue ActionController::UrlGenerationError => e
    if session[:detours]
      logger.error "Exception linking to origin: #{e.class} #{e}"
      pop_detour(session)
      retry
    end
    raise
  end
end
