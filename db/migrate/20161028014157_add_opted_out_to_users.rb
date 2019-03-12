class AddOptedOutToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :opted_out, :boolean, default: false, index: true
  end
end
