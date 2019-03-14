class AddAuthenticationTokenToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :authentication_token, :string, limit: 30
    add_index :users, :authentication_token, unique: true

    puts "Updating #{User.all.count} user records"
    User.all.each(&:save!)
  end

  def down
    remove_index :users, :authentication_token
    remove_column :users, :authentication_token
  end
end
