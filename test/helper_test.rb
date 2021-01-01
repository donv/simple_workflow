# frozen_string_literal: true

require_relative 'test_helper'
require 'action_controller/metal/exceptions'
require 'test_app'

class HelperTest < MiniTest::Test
  include SimpleWorkflow::Helper

  def test_with_detour
    assert_equal '?detour%5Baction%5D=myaction&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42' \
            '&detour%5Bquery%5D%5Bnested%5D=criterium',
                 with_detour('')
  end

  def test_with_detour_with_origin
    assert_equal '?detour%5Baction%5D=index&detour%5Bcontroller%5D=dashboard',
                 with_detour('', controller: :dashboard, action: :index)
  end

  def test_with_detour_with_only_anchor_as_origin
    assert_equal '?detour%5Baction%5D=myaction&detour%5Banchor%5D=tab_2' \
          '&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42&detour%5Bquery%5D%5Bnested%5D=criterium',
                 with_detour('', anchor: :tab_2)
  end

  module SimpleWorkflow::Controller
    def self.binary_params_for?(_action)
      false
    end
  end

  def test_with_detour_with_string_origin
    Rails.application = TestApp.new

    Rails.application.routes.draw do
      get 'dashboard/index' => 'simple_workflow/#index'
    end

    assert_equal '?detour%5Baction%5D=index&detour%5Banchor%5D=tab_2' \
            '&detour%5Bcontroller%5D=simple_workflow%2F&detour%5Bhullo%5D=1',
                 with_detour('', '/dashboard/index?hullo=1#tab_2')
  ensure
    Rails.application = nil
  end

  def test_detour_to
    assert_equal [
      'Link Text',
      'Link target?detour%5Baction%5D=myaction&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42' \
          '&detour%5Bquery%5D%5Bnested%5D=criterium',
      { id: 'link_tag_id', title: 'Link title' },
    ],
                 detour_to('Link Text', 'Link target', id: 'link_tag_id', title: 'Link title')
  end

  def test_image_button_to
    assert_equal [
      'my_image.png', {
        class: 'image-submit', alt: 'Link Title',
        title: 'Image title', id: 'Link Title_image_tag_id', name: 'Link Title',
        onclick: "form.action='{:id=>\"image_tag_id\"}'"
      }
    ],
                 image_button_to('my_image.png', 'Link Title', { id: 'image_tag_id' },
                                 title: 'Image title')
  end

  def test_image_link_to
    assert_equal [
      ['my_image.png', { title: 'Link Title', alt: 'Link Title' }], { id: 'image_tag_id' }, nil
    ],
                 image_link_to('my_image.png', 'Link Title', { id: 'image_tag_id' }, title: 'Image title')
  end

  def test_back_or_link_to
    assert_equal ['Link title', { controller: :mycontroller, action: :my_action }, nil],
                 back_or_link_to('Link title', controller: :mycontroller, action: :my_action)
  end

  def test_back_or_link_to_with_routing_error
    @session = { detours: [{ controller: :does_not_exist }] }
    @routing_error = ActionController::UrlGenerationError
    assert_equal ['Link title', { controller: :mycontroller, action: :my_action }, nil],
                 back_or_link_to('Link title', controller: :mycontroller, action: :my_action)
  end

  private

  def logger
    @logger ||= Logger.new(File.expand_path('../log/test.log', __dir__))
  end

  def params
    ActionController::Parameters.new(
        controller: 'mycontroller', action: 'myaction', id: 42, query: { nested: 'criterium' }
      )
  end

  def session
    @session ||= {}
  end

  def url_for(options)
    options.to_s
  end

  def link_to(*options)
    if defined?(@routing_error) && @routing_error
      e = @routing_error
      @routing_error = nil
      raise e
    end
    options
  end

  def image_tag(*args)
    args
  end

  def image_submit_tag(*args)
    args
  end
end
