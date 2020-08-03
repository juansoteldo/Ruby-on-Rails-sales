# frozen_string_literal: true

# Represents a kind of email sent to a lead, includes quotes, reminders, and follow-ups
class MarketingEmail < ApplicationRecord
  has_many :delivered_emails

  scope :quotes, -> { where email_type: "quote" }

  validates_presence_of :email_type
  validates_presence_of :days_after_state_change
  validates_numericality_of :days_after_state_change, minimum: 0

  def self.template_names
    ["24_hour_reminder_email", "24_hour_unquoted_reminder_email", "1_week_reminder_email",
     "2_week_reminder_email", "48_hour_follow_up_email", "2_week_follow_up_email"]
  end

  def self.quote_for_request(request)
    return nil unless request.auto_quotable?
    return find_by_template_name("first_time_quote_email") if request.first_time?

    request.tattoo_size.quote_email
  end

  def quote?
    email_type == "quote"
  end
end
