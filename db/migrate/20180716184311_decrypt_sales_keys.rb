class DecryptSalesKeys < ActiveRecord::Migration
  def change
    rename_column :salespeople, :encrypted_streak_api_key, :streak_api_key
  end
end
