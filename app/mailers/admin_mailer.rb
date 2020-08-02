# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def daily_blast_counts(counts)
    @counts = counts
    recipients = Rails.application.config.marketing_email_recipients
    recipients ||= []
    mail(to: recipients,
         subject: "Daily Marketing E-Mail Report")
  end
end
