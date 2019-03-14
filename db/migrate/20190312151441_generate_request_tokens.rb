class GenerateRequestTokens < ActiveRecord::Migration[5.2]
  def up
    remove_column :requests, :token, :string
    add_column :requests, :token, :uuid, index: true, unique: true
  end
end
