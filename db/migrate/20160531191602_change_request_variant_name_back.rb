class ChangeRequestVariantNameBack < ActiveRecord::Migration[4.2]
  def change
    rename_column :requests, :quote_variant, :variant
  end
end
