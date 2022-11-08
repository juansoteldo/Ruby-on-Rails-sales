class AddShopifySessionToAppConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configs, :shopify_session, :string
  end
end
