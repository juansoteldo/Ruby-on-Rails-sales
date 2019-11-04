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
end
