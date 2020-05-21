class AddSizeToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :size, :string
  end
end
