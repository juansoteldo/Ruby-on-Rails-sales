class AddVersionToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :version, :integer, default: 1
  end
end
