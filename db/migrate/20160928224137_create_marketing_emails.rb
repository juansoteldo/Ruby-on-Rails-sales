class CreateMarketingEmails < ActiveRecord::Migration
  def up
    create_table :marketing_emails do |t|
      t.string :state, index: true
      t.integer :days_after_state_change, index: true
      t.string :template_name
      t.string :from, default: 'orders@customtattoodesign.ca'
      t.string :template_path, default: 'box_mailer'
      t.string :subject_line, default: 'Lee Roller Owner / Custom Tattoo Design'
    end

    add_index :delivered_emails, :marketing_email_id

    require Rails.root.join 'db/seeds/marketing_emails'
  end

  def down
    remove_index :delivered_emails, :marketing_email_id

    drop_table :marketing_emails
  end
end
