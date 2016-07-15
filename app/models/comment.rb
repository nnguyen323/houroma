class Comment < ActiveRecord::Base
	belongs_to :activity
	belongs_to :user
  belongs_to :parent, class_name:   "Comment", foreign_key: "parent_id"
	has_many :comments, foreign_key: "parent_id", dependent: :destroy
  has_one :rating, as: :post, dependent: :destroy
  validates :user_id, presence:true
  validates :content, length: { maximum: 250 }, presence: true
  validates :depth, numericality: { only_integer: true, less_than_or_equal_to: 4, greater_than_or_equal_to: 0 }
  default_scope -> { order(created_at: :desc)}
end
