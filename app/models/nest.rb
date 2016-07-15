class Nest < ActiveRecord::Base
  belongs_to :action
  belongs_to :user  
  has_many :birds, dependent: :destroy  
  has_many :nesting_users, through: :birds,  source: :user

  VALID_CONTENT_REGEX = /\A[a-zA-z]\w*\z/
  validates :title, presence: true, format:
   { with: VALID_CONTENT_REGEX, message: "hashtags must start with a letter" }
  validates_length_of :title, maximum: 30, message: "must be 30 or less characters"

  def to_param
   title
  end

  def add_to_nest(user)
    birds.create(user_id: user.id);
  end

  #remove nest inhabitant
  def kill_bird(user)
    birds.find_by(user_id: user.id).destroy
  end

  #return true if the user is already in the nest
  def nesting?(user)
    nesting_users.include?(user)
  end  
end
