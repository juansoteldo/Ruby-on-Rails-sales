class AddGmailAndStreakIdsToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :streak_box_key, :string, index: true
    add_column :requests, :thread_gmail_id, :string, index: true
  end
end
