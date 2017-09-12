class AddBoxCountToSalesTotals < ActiveRecord::Migration
  def change
    add_column :sales_totals, :box_count, :integer, default: 0
  end
end
