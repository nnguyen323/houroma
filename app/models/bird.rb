class Bird < ActiveRecord::Base
   belongs_to :user
   belongs_to :nest
   validates :nest_id, presence: true
   validates :user_id, presence: true   
end
