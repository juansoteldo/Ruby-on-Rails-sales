class AddAdminToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :admin, :boolean
  end
end
