class AddTattooSizeIdToRequests < ActiveRecord::Migration[5.2]
  def up
    add_column :requests, :tattoo_size_id, :integer
    add_column :requests, :quoted_at, :datetime

    execute <<SQL
      UPDATE requests SET tattoo_size_id = (SELECT id FROM tattoo_sizes WHERE deposit_variant_id = variant)
      WHERE variant IS NOT NULL
SQL

    add_index :requests, [:tattoo_size_id, :quoted_at]
  end

  def down
    remove_column :requests, :tattoo_size_id, :integer
    remove_column :requests, :quoted_at, :datetime
  end

end
