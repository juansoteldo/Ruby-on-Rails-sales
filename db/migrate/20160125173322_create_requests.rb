class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :user, index: true, foreign_key: true
      t.string :token
      t.boolean :is_first_time
      t.string :gender
      t.boolean :has_color
      t.boolean :has_cover_up
      t.string :position
      t.string :large
      t.string :notes
      t.string :qid
      t.string :requesting_cid
      t.string :ticket_url

      t.timestamps null: false
    end
  end
end
