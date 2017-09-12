class AddContactedByToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :contacted_by_id, :integer, index: true
  end
end
