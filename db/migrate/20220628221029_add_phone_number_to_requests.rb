class AddPhoneNumberToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :phone_number, :string
  end
end
