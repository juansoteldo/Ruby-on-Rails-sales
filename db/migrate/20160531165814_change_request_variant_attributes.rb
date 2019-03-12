class ChangeRequestVariantAttributes < ActiveRecord::Migration[4.2]
  def change
    rename_column :requests, :variant, :quote_variant
    add_column :requests, :deposit_variant, :string
    add_column :requests, :quoted_by_id, :integer

    add_index :requests, [ :quoted_by_id ]
  end
end
