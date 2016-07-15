class AddCheckboxBoolForActivityRouting < ActiveRecord::Migration
  def change
  	add_column :users, :activation_route, :boolean, default: true
  end
end
