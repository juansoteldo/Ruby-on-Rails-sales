require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @request = requests(:fresh)
    @user = @request.user
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)
  end

  test "create_user" do
    assert_not_nil @request.user
    assert_not_nil @request.user.email
    assert_nil @request.user.marketing_opt_in
  end

  test "sends opt-in email" do
    assert_enqueued_emails(1) do
      Request.create! user: @user
    end
  end

  test "does not re-send opt-in" do
    assert_enqueued_emails(1) do
      Request.create! user: @user
      @user.update marketing_opt_in: false
      Request.create! user: @user
    end
  end

  test "re-opts-in user to pre-sales and crm, but not marketing" do
    @user.update presales_opt_in: false, marketing_opt_in: false, crm_opt_in: false
    assert_not @user.marketing_opt_in
    Request.create! user: @user
    assert @user.reload.presales_opt_in
    assert @user.crm_opt_in
    assert_not @user.marketing_opt_in
  end

  test "quote_from_params!" do
    @request.quote_from_params!({ variant_id: @variant.id, salesperson_id: @salesperson.id })
  end

  test "updates user names on save" do
    @request.update! first_name: SecureRandom.base64(8), last_name: SecureRandom.base64(8)
    assert_equal @user.reload.first_name, @request.first_name
    assert_equal @user.last_name, @request.last_name
  end

  test "doesn't update user names on save if they're empty" do
    @request.update! first_name: nil, last_name: nil
    assert_not_equal @user.reload.first_name, @request.first_name
    assert_not_equal @user.last_name, @request.last_name
  end

  test ".for_shopify_order uses request_id by default" do
    order = shopify_order_for_request(@request,
    {
        email: SecureRandom.base64(8),
        id: nil,
      }
    )

    request = Request.for_shopify_order(order)
    assert_not_nil request
    assert_equal "request_id", request.attributed_by
    assert_equal request&.id, @request.id

  end

  test ".for_shopify_order uses email if id not present" do
    order = last_deposit_order
    request = create_request_for_shopify_order(order)
    order.source.note_attributes[0][:value] = (@request.id + 1).to_s
    order.source.id = nil

    found_request = Request.for_shopify_order(order)
    assert_not_nil found_request
    assert_equal "email", found_request.attributed_by
    assert_equal found_request.user.email, request.user.email
  end

  test ".for_shopify_order uses fuzzy email if id not present" do
    order = last_deposit_order
    request = create_request_for_shopify_order(order)
    order.source.email[1] = "a"
    order.source.note_attributes[0][:value] = (@request.id + 1).to_s
    order.source.id = nil
    assert_not_equal request.user.email, order.email
    found_request = Request.for_shopify_order(order)
    assert_not_nil found_request
    assert_equal "fuzzy_email", found_request.attributed_by
    assert_equal found_request.user.email, request.user.email
  end

  def create_request_for_shopify_order(order, params = {})
    request = requests(:fresh)
    request.user.update email: order.email
    request.deposit_order_id = order.id
    request.variant = MostlyShopify::Variant.find(order.line_items.first.variant_id)
    request.assign_attributes params
    request.save
    request
  end

  def last_deposit_order
    order_count = MostlyShopify::Order.count({})

    MostlyShopify::Order.new ShopifyAPI::Order.all({limit: 1, page: order_count}).last
  end

  def shopify_order_for_request(request, params = {})
    order = MostlyShopify::Order.new shopify_params.merge(
      "email": @request.user.email,
      "note_attributes": [
        {
          "name": "req_id",
          "value": request.id.to_s,
        },
        {
          "name": "sales_id",
          "value": request.quoted_by_id,
        },
      ]
    ).merge(params)
    order
  end
end
