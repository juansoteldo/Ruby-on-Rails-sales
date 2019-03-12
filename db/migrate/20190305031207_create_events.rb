class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :uuid
      t.references :user, index: true, foreign_key: true
      t.integer :request_id, index: true

      t.string :source_type
      t.string :source

      t.datetime :starts_at, index: true
      t.datetime :ends_at

    end

    add_column :users, :phone_number, :string
    add_column :users, :timezone, :string
    add_column :users, :uuid, :string
  end
end
