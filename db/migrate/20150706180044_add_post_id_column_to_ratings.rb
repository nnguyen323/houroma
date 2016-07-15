class AddPostIdColumnToRatings < ActiveRecord::Migration
  def change
    add_reference :ratings, :post, polymorphic: true, index: true    
  end
end
