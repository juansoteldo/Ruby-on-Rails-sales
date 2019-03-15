class GenerateRequestUuids < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""
    remove_column :requests, :token, :string
    add_column :requests, :uuid, :uuid, index: true, unique: true, default: "uuid_generate_v4()"
  end

  def down
    add_column :requests, :token, :string, index: true
    execute "UPDATE requests SET token = uuid"
    remove_column :requests, :uuid, :uuid
  end
end
