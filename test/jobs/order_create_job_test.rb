require 'test_helper'

class OrderCreateJobTest < ActiveJob::TestCase

  def new_webhook(new_params)
    Webhook.create! source: "Shopify", action_name: "orders_create", params: shopify_params.dup.merge(new_params)
  end

  setup do
    @request = requests(:fresh)
    @salesperson = salespeople(:active)
    params = {
        "email": wpcf7_params[:email],
        "note_attributes": [
            {
                "name": "req_id",
                "value": @request.id.to_s,
            },
            {
                "name": "sales_id",
                "value": @salesperson.id,
            },
        ]
    }
    @webhook = new_webhook params
  end

  test "should update request with shopify order" do
    OrdersCreateJob.perform_now webhook: @webhook
    assert @webhook.reload.committed?
    assert_equal @request.reload.quoted_by_id, @salesperson.id
    assert_not_nil @request.deposit_order_id
  end

  test "should mark webhook as failed on failure" do
    @request.destroy!
    OrdersCreateJob.perform_now webhook: @webhook
    assert @webhook.reload.failed?
    assert_not_nil @webhook.last_error
  end
end