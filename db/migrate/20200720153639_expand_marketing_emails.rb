class ExpandMarketingEmails < ActiveRecord::Migration[5.2]
  def up
    add_column :marketing_emails, :email_type, :string
    add_index :marketing_emails, [:email_type]
  end

  def down
    remove_column :marketing_emails, :email_type, :string
  end
end
