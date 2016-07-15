class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :tracker_id
      t.integer :tracked_id
      t.timestamps null: false
    end
    add_index :relationships, :tracker_id
    add_index :relationships, :tracked_id
    add_index :relationships, [:tracker_id, :tracked_id], unique: true
  end
end