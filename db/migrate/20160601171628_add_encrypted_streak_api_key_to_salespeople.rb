class AddEncryptedStreakApiKeyToSalespeople < ActiveRecord::Migration[4.2]
  def change
    add_column :salespeople, :encrypted_streak_api_key, :string
  end
end
