class RemoveActraitsTable < ActiveRecord::Migration
  def change
    drop_table :actraits
  end
end
