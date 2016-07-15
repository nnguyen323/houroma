class AddIndexToUserIdAndActionIdToMakeAUniqueKey < ActiveRecord::Migration
  def change
    add_index :nests, [:user_id, :action_id], unique:true
  end
end
