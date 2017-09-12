class MarketingEmail < ActiveRecord::Base
  has_many :delivered_emails

  def self.template_names
    ["24_hour_reminder_email", "1_week_reminder_email",
     "2_week_reminder_email", "48_hour_follow_up_email", "2_week_follow_up_email"] 
  end
end
