class AddDepthComments < ActiveRecord::Migration
  def change
    add_column  :comments, :depth, :integer
  end
end
