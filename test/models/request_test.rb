require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Request.skip_creating_streak_boxes = true
    @request = requests(:fresh)
    @user = @request.user
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)
  end

  teardown do
    Request.skip_creating_streak_boxes = false
  end

  test "create_user" do
    assert_not_nil @user
    assert_not_nil @user.email
    assert_nil @user.marketing_opt_in
  end

  test "sends opt-in email" do
    assert_enqueued_emails(1) do
      Request.create! user: @user
    end
  end

  test "does not re-send opt-in" do
      assert_enqueued_emails(0) do
        @user.update marketing_opt_in: false
        Request.create! user: @user
      end
  end

  test "re-opts-in user to pre-sales and crm, but not marketing" do
    @user.update! presales_opt_in: false, marketing_opt_in: false, crm_opt_in: false
    Request.create! user: @user
    assert @user.reload.presales_opt_in
    assert @user.crm_opt_in
    assert_not @user.marketing_opt_in
  end

  test "quote_from_params!" do
    @request.quote_from_params!({ variant_id: @variant.id, salesperson_id: @salesperson.id })
  end
end
