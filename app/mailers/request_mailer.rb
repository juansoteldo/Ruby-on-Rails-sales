# frozen_string_literal: true

# Mailer class responsible for sending initial request email
class RequestMailer < ApplicationMailer
  include ApplicationHelper
  default from: "Custom Tattoo Design <mailer@customtattoodesign.ca>"
  default display_name: "Custom Tattoo Design"

  def initialize
    super
    @subject_append = Settings.gmail.subject_append
  end

  def start_design_email(request, recipients = [Salesperson.system.email])
    @request = request.decorate
    @user = request.user
    subject_base = "New Start Design Request # #{request.id} - #{@request.full_name} (#{@user.email})"
    env = ENV["RAILS_ENV"]
    if env == "production"
      subject = subject_base
    else
      subject = "#{subject_base} [#{@subject_append}]"
    end
    headers["X-CTD-Streak-Box-Key"] = @request.streak_box_key
    mail(to: recipients,
         subject: subject,
         reply_to: @user.email)
  end
end
