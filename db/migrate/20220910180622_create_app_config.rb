class CreateAppConfig < ActiveRecord::Migration[5.2]
  def change
    create_table :app_configs do |t|
      t.string :shopify_access_token
    end
  end
end
