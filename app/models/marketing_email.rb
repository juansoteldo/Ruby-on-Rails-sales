# frozen_string_literal: true

class MarketingEmail < ApplicationRecord
  has_many :delivered_emails

  validates_presence_of :days_after_state_change
  validates_numericality_of :days_after_state_change, minimum: 0

  def self.template_names
    ["24_hour_reminder_email", "24_hour_unquoted_reminder_email", "1_week_reminder_email",
     "2_week_reminder_email", "48_hour_follow_up_email", "2_week_follow_up_email"]
  end
end
