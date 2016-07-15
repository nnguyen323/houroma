class RemoveRatingIdColumnFromActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :rating_id
  end
end
