class CreateTransactionalEmail < ActiveRecord::Migration[5.2]
  def change
    create_table :transactional_emails do |t|
      t.string :name
      t.string :smart_id
    end
    add_index :transactional_emails, :smart_id, unique: true
  end
end
