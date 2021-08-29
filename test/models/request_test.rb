require "test_helper"

class RequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Settings.streak.create_boxes = false
    @request = requests(:fresh)
    @user = @request.user
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)

    perform_enqueued_jobs do
      email = SecureRandom.hex(8);
      @fresh_user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
      @fresh_request = Request.create! user: @fresh_user, description: "TEST, DO NOT REPLY"

      @fresh_request.size = "Full Sleeve"
      @fresh_request.assign_tattoo_size_attributes
    end
  end

  teardown do
    Settings.streak.create_boxes = true
    # delete subscriber
    response = Services::CampaignMonitor.delete_subscriber(@fresh_user)
    assert_equal response.code, 200
  end

  test "create_user" do
    assert_not_nil @user
    assert_not_nil @user.email
    assert_nil @user.marketing_opt_in
  end

  test "sends opt-in email" do
    assert_enqueued_emails(0) do
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

  test "check_quote_urls" do
    perform_enqueued_jobs do
      @fresh_request.send_quote
      sleep 10

      response = Services::CampaignMonitor.get_subscriber_details_in_all(@fresh_user)

      assert_not_nil find_value_in_response(response: response, key: 'quote_url_base', value: @fresh_request.quote_url_base)

      assert_not_nil find_value_in_response(response: response, key: 'quote_url_signature', value: @fresh_request.quote_url_signature)

      assert_not_nil find_value_in_response(response: response, key: 'quote_url_utm_params', value: @fresh_request.quote_url_utm_params)
   end
  end

  test "salesperson_email" do
    perform_enqueued_jobs do
      @fresh_request.quoted_by = Salesperson.last
      @fresh_request.save!
      sleep 10

      response = Services::CampaignMonitor.get_subscriber_details_in_all(@fresh_user)

      assert_not_nil find_value_in_response(response: response, key: 'salesperson_email', value: @fresh_request.salesperson.email)
    end
  end

  test "requests_statuses" do
    perform_enqueued_jobs do
      @fresh_request.save!
      sleep 10

      response = Services::CampaignMonitor.get_subscriber_details_in_all(@fresh_user)

      assert_not_nil find_value_in_response(
        response: response, 
        key: 'requests_statuses', 
        value: @fresh_user.requests.map { |request| request.state }.join(',')
      )
    end
  end

  def find_value_in_response(response:, key:, value:)
    response.parsed_response['CustomFields'].find do |field| 
        field['Key'] == key && field['Value'] == value
    end
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
