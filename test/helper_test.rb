require_relative 'test_helper'

class HelperTest < MiniTest::Test
  include SimpleWorkflow::Helper

  def test_with_detour
    assert_equal '?detour%5Baction%5D=myaction&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42&detour%5Bquery%5D%5Bnested%5D=criterium',
        with_detour('')
  end

  def test_detour_to
    assert_equal [
      'Link Text',
      'Link target?detour%5Baction%5D=myaction&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42&detour%5Bquery%5D%5Bnested%5D=criterium',
      { id: 'link_tag_id', title: 'Link title' }
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
        image_button_to('my_image.png', 'Link Title', { id: 'image_tag_id' }, title: 'Image title')
  end

  def test_image_link_to
    assert_equal [
      ['my_image.png', { title: 'Link Title', alt: 'Link Title' }], { id: 'image_tag_id' }, nil
    ],
        image_link_to('my_image.png', 'Link Title', { id: 'image_tag_id' }, title: 'Image title')
  end

  private

  def params
    { controller: 'mycontroller', action: 'myaction', id: 42, query: { nested: 'criterium' } }
  end

  def url_for(options)
    options.to_s
  end

  def link_to(*options)
    options
  end

  def image_tag(*args)
    args
  end

  def image_submit_tag(*args)
    args
  end
end
