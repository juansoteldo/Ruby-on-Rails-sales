class AddUtmContentToAhoyMessages < ActiveRecord::Migration
  def change
    add_column :ahoy_messages, :utm_content, :string
  end
end
