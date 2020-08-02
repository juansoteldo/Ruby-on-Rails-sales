require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @request = requests(:fresh)
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)
  end

  test "" do
    assert Webhook.create(source: "Shopify", action_name: "orders_create").job_class == CommitShopifyOrderJob
    assert Webhook.create(source: "WordPress", action_name: "requests_create").job_class == CreateRequestJob
  end

  test "queues job on create" do
    params = shopify_params.merge(
      "email": @request.user.email,
      "note_attributes": [
        {
          "name": "req_id",
          "value": @request.id.to_s
        },
        {
          "name": "sales_id",
          "value": @request.quoted_by_id
        }
      ]
    )
    perform_enqueued_jobs do
      Webhook.create source: "Shopify", action_name: "orders_create", params: params, source_id: params[:id], referrer: "test123"
    end
    assert_not_nil @request.reload.deposit_order_id
  end
end
