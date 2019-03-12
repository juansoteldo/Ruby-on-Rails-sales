class AddContactedByToRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :contacted_by_id, :integer, index: true
  end
end
