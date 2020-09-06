# frozen_string_literal: true

# Represents a kind of email sent to a lead, includes quotes, reminders, and follow-ups
class MarketingEmail < ApplicationRecord
  has_many :delivered_emails

  scope :quotes, -> { where email_type: "quote" }
  scope :reminders, -> { where email_type: "reminder" }
  validates_presence_of :email_type
  validates_presence_of :days_after_state_change
  validates_numericality_of :days_after_state_change, minimum: 0

  def self.template_names
    all.order("email_type, days_after_state_change").map(&:template_name)
  end

  def mailer_method
    email_type == "quote" ? :quote_email : :marketing_email
  end

  def self.last_reminder_for_request(request)
    reminders.order("days_after_state_change")
             .where("days_after_state_change * 24 < ? AND state LIKE ?",
                    request.hours_since_state_change,
                    "%#{request.state}%").last
  end

  def self.quote_for_request(request)
    return nil unless request.auto_quotable?
    return find_by_template_name("first_time_quote_email") if request.first_time? && !request.sleeve?

    request.tattoo_size.quote_email
  end

  def quote?
    email_type == "quote"
  end

  def to_s
    "MarketingEmail ##{id} (#{template_name})"
  end
end
