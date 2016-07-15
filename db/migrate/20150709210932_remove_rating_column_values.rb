class RemoveRatingColumnValues < ActiveRecord::Migration
  def change
    remove_column :ratings, :value    
  end
end
