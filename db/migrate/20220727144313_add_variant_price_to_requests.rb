class AddVariantPriceToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :variant_price, :string
  end
end
