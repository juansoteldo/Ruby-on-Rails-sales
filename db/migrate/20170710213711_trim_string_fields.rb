class TrimStringFields < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE requests SET
           first_name = TRIM(first_name),
           last_name = TRIM(last_name),
           position = TRIM(position)"
    execute "UPDATE requests SET position = 'Sleeve Left' WHERE position = 'Left'"
    execute "UPDATE requests SET position = 'Sleeve Right' WHERE position = 'Right'"
  end

  def down; end
end
