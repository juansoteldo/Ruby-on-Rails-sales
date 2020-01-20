class RequestMailer < ApplicationMailer
  default from: "Custom Tattoo Design <katie@customtattoodesign.ca>"
  default display_name: "Custom Tattoo Design"

  def start_design_email(request)
    @request = request
    @user = request.user
    subject = "New Start Design Request - #{request.full_name} (#{@user.email})"
    subject = "[TEST] " + subject unless Rails.env.production?
    headers["X-CTD-Streak-Box-Key"] = @request.streak_box_key
    mail(to: "sales@customtattoodesign.ca",
         subject: subject,
         reply_to: @user.email)
  end
end