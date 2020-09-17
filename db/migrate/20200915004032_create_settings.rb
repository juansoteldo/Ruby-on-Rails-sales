class CreateSettings < ActiveRecord::Migration[5.2]
  def up
    create_table :settings do |t|
      t.string :name
      t.string :data_type, default: "boolean"
      t.string :value
    end

    add_index :settings, :name, unique: true

    Setting.create!(name: "Auto-quoting", value: false, data_type: "boolean")
  end

  def down
    drop_table :settings
  end
end
