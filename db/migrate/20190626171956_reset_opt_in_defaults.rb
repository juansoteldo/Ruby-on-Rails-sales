class ResetOptInDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :marketing_opt_in, :boolean, default: nil
  end
end
