class Rate < ActiveRecord::Base
  belongs_to :rating
  belongs_to :user

  def toggle_up
  	update(up: !up)
  end
end