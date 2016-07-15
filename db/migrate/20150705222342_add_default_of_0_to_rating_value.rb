class AddDefaultOf0ToRatingValue < ActiveRecord::Migration
  def up
    change_column :ratings, :value, :integer, :default => 0
  end

  def down
    change_column :ratings, :value, :integer, :default => nil
  end
end
