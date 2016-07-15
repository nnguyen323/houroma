class AddRatingIdToActivity < ActiveRecord::Migration
  def change
    add_column  :activities, :rating_id, :integer
    add_index   :activities, :rating_id    
  end
end
