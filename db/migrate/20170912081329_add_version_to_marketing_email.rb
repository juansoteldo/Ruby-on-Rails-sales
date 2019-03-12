class AddVersionToMarketingEmail < ActiveRecord::Migration[4.2]
  def change
    add_column :marketing_emails, :version, :integer, default: 1
  end
end
