class AddEncryptedStreakApiKeyToSalespeople < ActiveRecord::Migration
  def change
    add_column :salespeople, :encrypted_streak_api_key, :string
  end
end
