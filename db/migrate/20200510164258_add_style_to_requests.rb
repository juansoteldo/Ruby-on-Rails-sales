class AddStyleToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :style, :string
  end
end
