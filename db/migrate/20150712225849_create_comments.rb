class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.string :content
    	t.references :user, index: true, foreign_key: true
    	t.references :activity, index: true, foreign_key: true
    	t.integer :parent_id
      t.timestamps null: false
    end
    add_index :comments, :parent_id 
    add_index :comments, [:user_id, :created_at], unique: true
  end
end