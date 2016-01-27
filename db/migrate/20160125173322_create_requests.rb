class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :user, index: true, foreign_key: true

      t.string :first_name, default: ""
      t.string :last_name, default: ""

      t.string :token
      t.boolean :is_first_time
      t.string :gender
      t.boolean :has_color
      t.boolean :has_cover_up
      t.string :position
      t.string :large
      t.string :notes
      t.string :quote_id
      t.string :client_id
      t.string :ticket_id

      t.timestamps null: false
    end
  end
end
