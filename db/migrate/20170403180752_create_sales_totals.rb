class CreateSalesTotals < ActiveRecord::Migration
  def change
    create_table :sales_totals do |t|
      t.date :sold_on, index: true
      t.references :salesperson, index: true, foreign_key: true
      t.decimal :order_total, default: 0
      t.integer :order_count, default: 0
    end

    add_index :sales_totals, [ :sold_on, :salesperson_id ]
  end
end
