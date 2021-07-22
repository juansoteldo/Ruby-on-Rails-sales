require "test_helper"

class RequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Settings.streak.create_boxes = false
    @request = requests(:fresh)
    @user = @request.user
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)
  end

  teardown do
    Settings.streak.create_boxes = true
  end

  test "create_user" do
    assert_not_nil @user
    assert_not_nil @user.email
    assert_nil @user.marketing_opt_in
  end

  test "sends opt-in email" do
    assert_enqueued_emails(1) do
      request = Request.create! user: @user, description: "TEST, DO NOT REPLY"
      request.opt_in_user
    end
  end

  test "does not re-send opt-in" do
    assert_enqueued_emails(0) do
      @user.update marketing_opt_in: false
      request = Request.create! user: @user, description: "TEST, DO NOT REPLY"
      request.opt_in_user
    end
  end

  test ".auto_quotable?" do
    @request.size = "Medium"
    @request.style = "Traditional"
    assert @request.auto_quotable?
    @request.size = "Don't Know"
    assert_not @request.auto_quotable?
    @request.size = "Half Sleeve"
    assert @request.auto_quotable?
  end

  test "quote_from_params!" do
    settings(:auto_quoting).update! value: false
    @request.quote_from_params!({ variant_id: @variant.id, salesperson_id: @salesperson.id })
  end

  test ".sleeve?" do
    @request.size = "Half Sleeve"
    assert @request.sleeve?
    @request.size = "Nothing"
    assert_not @request.sleeve?
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
    order = last_deposit_order
    request = create_request_for_shopify_order(order)
    order.source.email = SecureRandom.base64(8)
    order.source.note_attributes = [
      {
        "name": "req_id",
        "value": request.id.to_s
      },
      {
        "name": "sales_id",
        "value": nil
      }
    ]
    order.source.id = nil

    found_request = Request.for_shopify_order(order)
    assert_not_nil found_request
    assert_equal "request_id", found_request.attributed_by
    assert_equal found_request&.id, request.id
  end

  test ".for_shopify_order uses email if id not present" do
    order = last_deposit_order
    request = create_request_for_shopify_order(order)
    order.request_id = request.id + 1
    order.source.id = nil

    found_request = Request.for_shopify_order(order)
    assert_not_nil found_request
    assert_equal "email", found_request.attributed_by
    assert_equal found_request.user.email, request.user.email
  end

  test ".for_shopify_order uses fuzzy email if id not present" do
    order = last_deposit_order
    request = create_request_for_shopify_order(order)
    order.source.email[1] = "+"
    order.request_id = request.id + 1
    order.source.id = nil
    assert_not_equal request.user.email, order.email
    found_request = Request.for_shopify_order(order)
    assert_not_nil found_request
    assert_equal "fuzzy_email", found_request.attributed_by
    assert_equal found_request.user.email, request.user.email
  end

  test "send_quote" do
    email = SecureRandom.hex(8);
    user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
    request = Request.create! user: user, description: "TEST, DO NOT REPLY"
    
    request.size = "Full Sleeve"
    request.assign_tattoo_size_attributes
    request.send_quote

    sleep 15

    response = Services::CampaignMonitor.get_subscriber_details_in_all(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Active'

    response = Services::CampaignMonitor.get_subscriber_details_in_marketing(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Active'

    # delete subscriber
    response = Services::CampaignMonitor.delete_subscriber(user)
    assert_equal response.code, 200
 end

  def create_request_for_shopify_order(order, params = {})
    request = requests(:fresh)
    request.user.update email: order.email
    request.deposit_order_id = order.id
    request.variant = MostlyShopify::Variant.find(order.line_items.first.variant_id)
    request.assign_attributes params
    request.save
    request.update(id: order.request_id) if order.request_id
    request
  end

  def last_deposit_order
    order_count = MostlyShopify::Order.count({})

    order = MostlyShopify::Order.new(ShopifyAPI::Order.all({ limit: 1, page: order_count }).last)
    order
  end

  def shopify_order_for_request(request, params = {})
    order = MostlyShopify::Order.new shopify_params.merge(
      "email": @request.user.email,
      "note_attributes": [
        {
          "name": "req_id",
          "value": request.id.to_s
        },
        {
          "name": "sales_id",
          "value": request.quoted_by_id
        }
      ]
    ).merge(params)
    order
  end
end
