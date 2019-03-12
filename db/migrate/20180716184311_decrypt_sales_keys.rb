class DecryptSalesKeys < ActiveRecord::Migration[4.2]
  def change
    rename_column :salespeople, :encrypted_streak_api_key, :streak_api_key
  end
end
