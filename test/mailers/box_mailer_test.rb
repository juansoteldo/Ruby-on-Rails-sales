require "test_helper"

class BoxMailerTest < ActionMailer::TestCase
  def get_urls(string)
    regexp = %r{(^$)|(^(http|https)://[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?/.*)?$)}ix
    string.scan(regexp)
  end

  setup do
    @request = requests(:fresh)
    CTD::SeedImporter.import_marketing_emails
    CTD::SeedImporter.import_tattoo_sizes
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
    # opt in email disabled by Declyn request at 12.08.2021
    # because company wants switch opt-in email to campaign monitor. 
    return true

    # Create the email and store it for further assertions
    email = BoxMailer.opt_in_email(@request)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal [Settings.emails.lee], email.from
    assert_equal [@request.user.email], email.to
    assert_equal "E-Mail opt-in Custom Tattoo Design", email.subject
    user_token = "user_token=" + CGI.escape(@request.user.authentication_token)
    user_email = "user_email=" + CGI.escape(@request.user.email)
    assert(email.parts.any? { |part| part.body.to_s.include? user_token })
    assert(email.parts.any? { |part| part.body.to_s.include? user_email })
  end

  # TODO: broken test on test environment.
  # test "AWS quote emails include link" do
  #   @request.size = "Full Sleeve"
  #   @request.assign_tattoo_size_attributes
  #   settings(:auto_quoting).update! value: true
  #   email = BoxMailer.quote_email(@request)

  #   assert_emails 1 do
  #     email.deliver_now
  #   end

  #   assert_equal [@request.user.email], email.to
  #   # Broken: assert(email.parts.any? { |part| part.body.to_s.include? CGI.escape(@request.tattoo_size.deposit_variant_id) })
  #   variant = Variant.find(@request.tattoo_size.deposit_variant_id.to_i)
  #   product = variant.product
  #   handle = CGI.escape(product.handle)
  #   # Broken: assert(email.parts.any? { |part| part.body.to_s.include? handle })
  # end

  test "quote emails bcc notification recipients" do
    @request.size = "Full Sleeve"
    @request.assign_tattoo_size_attributes
    settings(:auto_quoting).update! value: true
    email = BoxMailer.quote_email(@request)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@request.user.email], email.to
    assert(Settings.emails.notification_recipients.all? { |bcc| email.bcc.include?(bcc) })
  end
end
