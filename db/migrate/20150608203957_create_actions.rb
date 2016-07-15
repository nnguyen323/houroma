class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :content
      t.integer :live_users
      t.timestamps null: false
    end
    add_index :actions, :content, unique: true
    add_index :actions, :live_users
  end
end