class AddDescriptionToRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :description, :text
  end
end
