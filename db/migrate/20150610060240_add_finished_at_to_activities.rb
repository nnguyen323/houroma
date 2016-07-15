class AddFinishedAtToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :finished_at, :datetime
  end
end
