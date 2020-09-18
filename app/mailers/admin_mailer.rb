# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def daily_blast_counts
    recipients = Settings.emails.notification_recipients
    recipients ||= []
    mail(to: recipients, subject: "Daily Marketing E-Mail Report")
  end
end
