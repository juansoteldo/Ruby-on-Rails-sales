class CreateProductsAndVariants < ActiveRecord::Migration[5.2]
  def change
    create_table :variants do |t|
      t.string :product_id
      t.string :title
      t.string :price
      t.string :fulfillment_service
      t.string :option1
      t.string :option2
      t.string :option3
    end
    add_index :variants, :product_id

    create_table :products do |t|
      t.string :title
      t.string :handle
    end
  end
end
