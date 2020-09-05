# frozen_string_literal: true

# Mailer class responsible for sending initial request email
class RequestMailer < ApplicationMailer
  include ApplicationHelper
  default from: "Custom Tattoo Design <mailer@customtattoodesign.ca>"
  default display_name: "Custom Tattoo Design"

  def start_design_email(request)
    @request = request.decorate
    @user = request.user
    subject = "New Start Design Request - #{@request.full_name} (#{@user.email})"
    subject = "[TEST] " + subject unless Rails.env.production?
    headers["X-CTD-Streak-Box-Key"] = @request.streak_box_key
    to = if Settings.emails.auto_quoting_enabled && !request.auto_quotable?
           "leeroller@customtattoodesign.ca"
         else
           "sales@customtattoodesign.ca"
         end
    mail(to: to,
         subject: subject,
         reply_to: @user.email)
  end
end
