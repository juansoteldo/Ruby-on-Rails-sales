class AddIndicesToRequests < ActiveRecord::Migration[5.2]
  def change
    add_index :requests, [:first_name, :last_name], name: :request_names
  end
end
