class AddUserKeyToSalespeople < ActiveRecord::Migration[4.2]
  def change
    add_column :salespeople, :user_key, :string
  end
end
