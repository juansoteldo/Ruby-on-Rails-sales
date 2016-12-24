class AddUserKeyToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :user_key, :string
  end
end
