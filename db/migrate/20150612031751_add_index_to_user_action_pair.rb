class AddIndexToUserActionPair < ActiveRecord::Migration
  def change
  	add_index :actraits, [:user_id, :action_id], unique:true
  end
end
