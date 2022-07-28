# frozen_string_literal: true

# Mailer class responsible for sending initial request email
class RequestMailer < ApplicationMailer
  include ApplicationHelper
  default from: "Custom Tattoo Design <mailer@customtattoodesign.ca>"
  default display_name: "Custom Tattoo Design"

  def start_design_email(request, recipients = [Salesperson.system.email])
    @request = request.decorate
    @user = request.user
    subject = "New Start Design Request - #{@request.full_name} (#{@user.email})"
    subject = "[#{ENV["RAILS_ENV"]}] #{subject}" unless Rails.env.production?
    headers["X-CTD-Streak-Box-Key"] = @request.streak_box_key

    mail(to: recipients,
         subject: subject,
         reply_to: @user.email)
  end
end
