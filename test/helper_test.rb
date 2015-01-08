require_relative 'test_helper'

class HelperTest < MiniTest::Test
  include SimpleWorkflow::Helper

  def test_with_detour
    assert_equal '?detour%5Baction%5D=myaction&detour%5Bcontroller%5D=mycontroller&detour%5Bid%5D=42&detour%5Bquery%5D%5Bnested%5D=criterium',
                 with_detour('')
  end

  private

  def params
    {controller: 'mycontroller', action: 'myaction', id: 42, query: {nested: 'criterium'}}
  end

  def url_for(options)
    options.to_s
  end
end
