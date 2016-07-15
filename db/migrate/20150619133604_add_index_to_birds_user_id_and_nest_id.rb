class AddIndexToBirdsUserIdAndNestId < ActiveRecord::Migration
  def change
    add_index :birds, [:user_id, :nest_id], unique:true    
  end
end
