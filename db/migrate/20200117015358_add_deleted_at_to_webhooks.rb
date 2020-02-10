class AddDeletedAtToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :deleted_at, :datetime
    add_index :webhooks, :deleted_at
  end
end
