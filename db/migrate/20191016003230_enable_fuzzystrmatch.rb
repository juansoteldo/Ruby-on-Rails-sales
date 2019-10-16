class EnableFuzzystrmatch < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
  end

  def down; end
end
