class AddActionIdToActivities < ActiveRecord::Migration
  def change
    add_column  :activities, :action_id, :integer
    add_index   :activities, :action_id
  end
end
