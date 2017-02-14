class AddIsActiveToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :is_active, :boolean
  end
end
