class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :action
  has_one :rating, as: :post, dependent: :destroy
  has_many :comments, dependent: :destroy
  default_scope -> { order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence:true
  validates :content, length: { maximum: 200 }
  validates :action_id, presence:true
  validate :picture_size

  private
  	def picture_size
  		if picture.size > 5.megabytes
  			errors.add(:picture, "should be less than 5MB")
  		end
  	end
end
