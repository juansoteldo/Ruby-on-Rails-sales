require "test_helper"

class RequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Settings.streak.create_boxes = false
    Settings.emails.auto_quoting_enabled = true
    request = requests(:deposited)
    @request = requests(:fresh)
    @user = @request.user
    @request.style = Request::TATTOO_STYLES.first
    @variant = MostlyShopify::Variant.all.first
    @salesperson = salespeople(:active)
  end

  teardown do
    Settings.emails.auto_quoting_enabled = false
    Settings.streak.create_boxes = true
  end

  test "quote_for_request returns first time" do
    @request.size = TattooSize.first.name
    @request.user.requests.where.not(id: @request.id).delete_all
    @request.assign_tattoo_size_attributes
    assert MarketingEmail.quote_for_request(@request).template_name.include?("first")
  end

  test "quote_for_request returns sleeve" do
    tattoo_size = tattoo_sizes(:full_sleeve)
    @request.size = tattoo_size.name
    @request.assign_tattoo_size_attributes
    assert_equal MarketingEmail.quote_for_request(@request).template_name, tattoo_size.quote_template_name
  end

  test "quote_for_request returns half sleeve" do
    tattoo_size = tattoo_sizes(:half_sleeve)
    @request.size = tattoo_size.name
    @request.assign_tattoo_size_attributes
    assert_equal MarketingEmail.quote_for_request(@request).template_name, tattoo_size.quote_template_name
  end

  test "quote_for_request returns proper size" do
    TattooSize.all.each do |size|
      @request.size = size.name
      next unless @request.auto_quotable?

      @request.assign_tattoo_size_attributes
      assert_equal MarketingEmail.quote_for_request(@request).template_name, size.quote_template_name
    end
  end
end
