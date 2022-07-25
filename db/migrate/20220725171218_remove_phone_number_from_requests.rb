class RemovePhoneNumberFromRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :requests, :phone_number, :string
  end
end
