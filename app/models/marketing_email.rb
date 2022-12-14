# frozen_string_literal: true

# Represents a kind of email sent to a lead, includes quotes, reminders, and follow-ups
class MarketingEmail < ApplicationRecord
  has_many :delivered_emails

  scope :quotes, -> { where email_type: "quote" }
  scope :reminders, -> { where email_type: "reminder" }
  scope :follow_ups, -> { where email_type: "follow-up" }
  scope :not_quotes, -> { where.not email_type: "quote" }

  before_validation :defang, if: :quote?
  validates_presence_of :email_type
  validates :days_after_state_change, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def self.template_names
    all.order("email_type, days_after_state_change").map(&:template_name)
  end

  attr_accessor :mailer_method
  def mailer_method
    @mailer_method ||= email_type == "quote" ? :quote_email : :marketing_email
  end

  def self.last_relevant_for_request(request)
    not_quotes.order("days_after_state_change")
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

  private

  def defang
    self.state = "-"
    self.days_after_state_change = nil
  end
end
