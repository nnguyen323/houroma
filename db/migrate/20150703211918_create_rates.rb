class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.references :rating, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true      
      t.timestamps null: false
    end
    add_index :rates, [:rating_id, :user_id], unique: true
  end
end