class AddGmailAndStreakIdsToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :streak_box_id, :string, index: true
    add_column :requests, :gmail_message_id, :string, index: true
  end
end
