class AddOptedOutToUsers < ActiveRecord::Migration
  def change
    add_column :users, :opted_out, :boolean, default: false, index: true
  end
end
