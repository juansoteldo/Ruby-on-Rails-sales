class AddAasmStateToDeliveredEmails < ActiveRecord::Migration[5.2]
  def up
    add_column :delivered_emails, :aasm_state, :string
    add_column :delivered_emails, :exception, :string

    execute "UPDATE delivered_emails SET aasm_state = 'fresh'"
    execute "UPDATE delivered_emails SET aasm_state = 'delivered' WHERE sent_at IS NOT NULL"
    add_index :delivered_emails, [:aasm_state]
    execute <<~SQL
      UPDATE delivered_emails SET aasm_state = 'skipped'
      WHERE request_id IN
        (
        SELECT requests.id
          FROM requests INNER JOIN users ON requests.user_id = users.id
        WHERE users.presales_opt_in = FALSE
        )
      AND aasm_state != 'delivered'
    SQL
  end

  def down
    remove_column :delivered_emails, :aasm_state, :string
    remove_column :delivered_emails, :exception, :string
  end
end
