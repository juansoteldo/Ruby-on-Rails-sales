class ChangeRequestVariantNameBack < ActiveRecord::Migration
  def change
    rename_column :requests, :quote_variant, :variant
  end
end
