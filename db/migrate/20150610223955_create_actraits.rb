class CreateActraits < ActiveRecord::Migration
  def change
    create_table :actraits do |t|
      t.references :user, index: true, foreign_key: true
      t.references :action, index: true, foreign_key: true
      t.integer :total_time
      t.integer :executions
      t.timestamps null: false
    end
  end
end
