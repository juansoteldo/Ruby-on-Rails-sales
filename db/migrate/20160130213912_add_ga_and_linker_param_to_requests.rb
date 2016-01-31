class AddGaAndLinkerParamToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :_ga, :string
    add_column :requests, :linker_param, :string
  end
end
