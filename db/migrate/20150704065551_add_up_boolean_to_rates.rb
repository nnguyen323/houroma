class AddUpBooleanToRates < ActiveRecord::Migration
  def change
    add_column :rates, :up, :boolean, default: true    
  end
end