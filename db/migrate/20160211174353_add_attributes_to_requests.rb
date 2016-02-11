class AddAttributesToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :handle, :string
    add_column :requests, :variant, :string
    add_column :requests, :last_visited_at, :datetime
  end
end
