class AddShopifyAddOrderActions < ActiveRecord::Migration[5.2]
  def change
    create_table :shopify_add_order_actions do |t|
      t.string :order_id
      t.string :webhook_id
      t.integer :salesperson_id
      t.datetime :created_at
    end
  end
end
