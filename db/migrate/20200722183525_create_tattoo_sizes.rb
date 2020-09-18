class CreateTattooSizes < ActiveRecord::Migration[5.2]
  def up
    create_table :tattoo_sizes do |t|
      t.string :name, index: true, null: false
      t.string :deposit_variant_id, index: true
      t.integer :order, index: true
      t.integer :size, index: true
      t.integer :quote_email_id, index: true

      t.timestamps
    end
  end

  def down
    drop_table :tattoo_sizes
  end
end
