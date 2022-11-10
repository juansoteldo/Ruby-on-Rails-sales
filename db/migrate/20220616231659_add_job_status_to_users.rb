class AddJobStatusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :job_status, :string
  end
end
