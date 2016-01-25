class CreateProductVariants < ActiveRecord::Migration
  def change
    create_table :product_variants do |t|
      t.references :product, index: true, foreign_key: true
      t.string :shopify_id
      t.boolean :has_color
      t.boolean :has_cover_up

      t.timestamps null: false
    end
  end
end
