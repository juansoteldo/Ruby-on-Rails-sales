# frozen_string_literal: true

# Mailer class responsible for sending initial request email
class RequestMailer < ApplicationMailer
  include ApplicationHelper
  default from: "Custom Tattoo Design <mailer@customtattoodesign.ca>"
  default display_name: "Custom Tattoo Design"

  def start_design_email(request, recipient = Settings.emails.system)
    @request = request.decorate
    @user = request.user
    subject = "New Start Design Request - #{@request.full_name} (#{@user.email})"
    subject = "[TEST] " + subject unless Rails.env.production?
    headers["X-CTD-Streak-Box-Key"] = @request.streak_box_key

    mail(to: recipient,
         subject: subject,
         reply_to: @user.email)
  end
end
