class CreateDeliveredEmails < ActiveRecord::Migration
  def change
    create_table :delivered_emails do |t|
      t.references :request, index: true, foreign_key: true
      t.integer :marketing_email_id
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end
