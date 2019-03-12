class AddIsActiveToSalespeople < ActiveRecord::Migration[4.2]
  def change
    add_column :salespeople, :is_active, :boolean
  end
end
