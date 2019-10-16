class AddAttributedByToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :attributed_by, :string
  end
end
