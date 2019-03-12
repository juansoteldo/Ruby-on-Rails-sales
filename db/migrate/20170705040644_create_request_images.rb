class CreateRequestImages < ActiveRecord::Migration[4.2]
  def change
    create_table :request_images do |t|
      t.references :request, index: true, foreign_key: true
      t.string :file

      t.timestamps null: false
    end
  end
end
