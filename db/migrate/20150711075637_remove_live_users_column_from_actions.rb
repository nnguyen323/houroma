class RemoveLiveUsersColumnFromActions < ActiveRecord::Migration
  def change
    remove_column :actions, :live_users        
  end
end
