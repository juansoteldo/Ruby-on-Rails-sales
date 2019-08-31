class AddTriesToWebhooks < ActiveRecord::Migration[5.2]
  def up
    add_column :webhooks, :tries, :integer, default: 0
    execute "UPDATE webhooks SET tries = 1 WHERE aasm_state IN ('committed', 'failed')"
  end

  def down
    remove_column :webhooks, :tries
  end
end
