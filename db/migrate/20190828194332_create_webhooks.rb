class CreateWebhooks < ActiveRecord::Migration[5.2]
  def change
    create_table :webhooks do |t|
      t.string :source, index: true, null: false
      t.string :source_id, index: true
      t.string :action, null: false
      t.string :params
      t.string :headers
      t.string :referrer
      t.integer :request_id, index: true
      t.string :last_error

      t.timestamps
    end

    add_index :webhooks, [:source, :action]
    add_index :webhooks, [:source, :source_id, :action]
  end
end
