class AddAdminToSalespeople < ActiveRecord::Migration[4.2]
  def change
    add_column :salespeople, :admin, :boolean
  end
end
