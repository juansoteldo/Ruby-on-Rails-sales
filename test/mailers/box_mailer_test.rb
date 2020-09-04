require "test_helper"

class BoxMailerTest < ActionMailer::TestCase
  def get_urls(string)
    regexp = %r{(^$)|(^(http|https)://[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?/.*)?$)}ix
    string.scan(regexp)
  end

  setup do
    @request = requests(:fresh)
  end

  test "marketing_emails render and include opt-out token" do
    marketing_email = MarketingEmail.first
    email = BoxMailer.marketing_email(@request, marketing_email)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@request.user.email], email.to
    assert_equal marketing_email.subject_line, email.subject
    assert marketing_email.from.include?(email.from.first)
    assert email.parts.all? { |part| part.body.to_s.include? CGI.escape(@request.user.authentication_token) }
  end

  test "opt_in_email" do
    # Create the email and store it for further assertions
    email = BoxMailer.opt_in_email(@request)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ["leeroller@customtattoodesign.ca"], email.from
    assert_equal [@request.user.email], email.to
    assert_equal "E-Mail opt-in Custom Tattoo Design", email.subject
    token = CGI.escape(@request.user.authentication_token)
    assert(email.parts.all? { |part| part.body.to_s.include? "user_token=#{token}" })
    assert(email.parts.all? { |part| part.body.to_s.include? "user_email=#{token}" })
  end

  test "quote emails include link" do
    @request.size = "Full Sleeve"
    @request.assign_tattoo_size_attributes
    Settings.emails.auto_quoting_enabled = true
    email = BoxMailer.quote_email(@request)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@request.user.email], email.to
    assert(email.parts.any? { |part| part.body.to_s.include? CGI.escape(@request.tattoo_size.deposit_variant_id) })
    variant = MostlyShopify::Variant.find(@request.tattoo_size.deposit_variant_id.to_i).first
    product = variant.product
    handle = CGI.escape(product.handle)
    assert(email.parts.any? { |part| part.body.to_s.include? handle })
  end

  test "quote emails bcc notification recipients" do
    @request.size = "Full Sleeve"
    @request.assign_tattoo_size_attributes
    Settings.emails.auto_quoting_enabled = true
    email = BoxMailer.quote_email(@request)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@request.user.email], email.to
    assert(Settings.emails.notification_recipients.all? { |bcc| email.bcc.include?(bcc) })
  end
end
