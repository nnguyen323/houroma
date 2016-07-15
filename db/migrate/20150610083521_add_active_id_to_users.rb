class AddActiveIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active_id, :integer
  end
end
