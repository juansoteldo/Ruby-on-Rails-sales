class ExpandMarketingEmails < ActiveRecord::Migration[5.2]
  def up
    add_column :marketing_emails, :email_type, :string

    MarketingEmail.all.each do |email|
      if email.template_path.end_with?("reminders")
        email.update_columns email_type: "reminder"
      elsif email.template_path.end_with?("quotes")
        email.update_columns email_type: "quote"
      else
        email.update_columns email_type: "follow_up"
      end
    end

    require Rails.root.join("db/seeds/marketing_emails.rb") unless Rails.env.test?
    add_index :marketing_emails, [:email_type]
  end

  def down
    remove_column :marketing_emails, :email_type, :string
  end
end
