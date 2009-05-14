require 'url_for_fix'

module ApplicationHelper
  include UserSystem
  include UrlForFix
  
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
  
  def back_or_link_to(title, options = nil)
    if session[:detours]
      options = {:return_from_detour => true}.update(session[:detours].last)
      logger.debug "linked return from detour: #{options}"
    end
    link_to(title, options) if options
  end
  
  def l(value)
    return t(value) if value.is_a?(Symbol)
  end
  
  def t(time_as_float)
    return super if time_as_float.is_a?(Symbol)
    return '' unless time_as_float
    time_as_float = BigDecimal(time_as_float.to_s) unless time_as_float.is_a? BigDecimal
    "#{time_as_float.to_i}:#{'%02d' % (time_as_float.frac * 60).round}" 
  end
  
  def h(object)
    if object.is_a? Time
      object.strftime '%Y-%m-%d %H:%M:%S'
    else
      super object
    end
  end
  
  def resolution_image(resolution)
    image_file = case resolution
    when Task::COMPLETED
    'checkmark.png'
    when Task::POSTPONED
    'arrow_right.png'
    when Task::MOVED
    'arrow_right.png'
    when Task::ABORTED
    'ernes_stop.png'
    else
      raise "Unknown resolution " + resolution
    end
    image_tag image_file, :title => l(@task.resolution.downcase)
  end
  
  def display_notice(page)
    if flash[:notice]
      page.replace_html :notice, flash[:notice]
      page.visual_effect(:appear, :notice)
      page.visual_effect(:highlight, :notice)
      flash.discard
    else
      page.visual_effect(:fade, :notice)
    end
  end
  
  def record(page, script)
    page.call("#{script};//")
  end
  
  def insert(page, content, selector, position = :top)
    escaped_content = content.gsub("\n", '').gsub("'", "\\\\'")
    record(page, "new Insertion.#{position.to_s.capitalize}($$('#{selector}').first(), '#{escaped_content}')")
  end
  
  def update_task(page)
    page["task_#{@task.id}"].replace render(:partial => "/tasks/task", :locals => { :task => @task, :i => 1, :active => true, :highlight_task => false, :update => :spotlight, :hidden => false })
  end
  
end
