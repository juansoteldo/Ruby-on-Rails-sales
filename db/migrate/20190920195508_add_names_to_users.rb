class AddNamesToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    execute <<SQL
      UPDATE users AS u
      SET first_name = r.first_name, last_name = r.last_name
      FROM requests AS r 
      WHERE r.first_name IS NOT NULL 
         AND r.first_name <> ''
         AND r.user_id = u.id
SQL
  end

  def remove
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
