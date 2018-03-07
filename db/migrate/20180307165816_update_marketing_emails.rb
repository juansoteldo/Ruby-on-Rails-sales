class UpdateMarketingEmails < ActiveRecord::Migration
  def change
    MarketingEmail.where(template_name: "24h_unquoted_email")
                  .update_all template_name: "24_hour_unquoted_reminder_email"
  end
end
