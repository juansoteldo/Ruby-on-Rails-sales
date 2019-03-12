class AddUtmContentToAhoyMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :ahoy_messages, :utm_content, :string
  end
end
