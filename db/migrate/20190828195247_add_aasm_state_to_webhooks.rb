class AddAasmStateToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :aasm_state, :string, index: true
  end
end
