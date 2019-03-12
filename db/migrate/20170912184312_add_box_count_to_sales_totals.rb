class AddBoxCountToSalesTotals < ActiveRecord::Migration[4.2]
  def change
    add_column :sales_totals, :box_count, :integer, default: 0
  end
end
