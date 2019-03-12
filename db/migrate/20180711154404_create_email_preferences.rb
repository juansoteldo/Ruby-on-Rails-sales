class CreateEmailPreferences < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :presales_opt_in, :boolean, default: true
    add_column :users, :marketing_opt_in, :boolean, default: true
    add_column :users, :crm_opt_in, :boolean, default: true
    execute "UPDATE users SET presales_opt_in = NOT opted_out AND marketing_opt_in = NOT opted_out " +
                "AND crm_opt_in = NOT opted_out"
    remove_column :users, :opted_out
  end

  def down
    add_column :users, :opted_out, :boolean, index: true
    execute "UPDATE users SET opted_out = (NOT presales_opt_in OR NOT marketing_opt_in OR NOT crm_opt_in)"
    remove_column :users, :presales_opt_in
    remove_column :users, :marketing_opt_in
    remove_column :users, :crm_opt_in
  end
end
