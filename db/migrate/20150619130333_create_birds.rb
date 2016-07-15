class CreateBirds < ActiveRecord::Migration
  def change
    create_table :birds do |t|
      t.references :user, index: true, foreign_key: true
      t.references :nest, index: true, foreign_key: true 
      t.timestamps null: false
    end
  end
end
