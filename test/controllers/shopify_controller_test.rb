require 'test_helper'

class ShopifyControllerTest < ActionController::TestCase
  test "should get products" do
    get :products
    assert_response :success
  end

  test "should get variants" do
    get :variants
    assert_response :success
  end

end
