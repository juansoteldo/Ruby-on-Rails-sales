class AddGaAndLinkerParamToRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :_ga, :string
    add_column :requests, :linker_param, :string
  end
end
