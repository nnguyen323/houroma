class Rating < ActiveRecord::Base
  has_many :rates, dependent: :destroy
  belongs_to :post, :polymorphic => true
  belongs_to :activity, -> { where(ratings: {post_type: 'Activity'}) }, foreign_key: 'post_id'
  belongs_to :comment, -> { where(ratings: {post_type: 'Comment'}) }, foreign_key: 'post_id'
  #rate a user
  def rate(user, up)
    rate = rates.find_by(user_id: user.id)
    if !rate
      rate = rates.create(user_id: user.id, up: up)
    end
    return rate
  end

  #unrate a user
  def unrate(user)
    rate = rates.find_by(user_id: user.id)
    if rate
      rate.destroy
    end
  end

  #return true if the current user has already rated the other user
  def rating?(user)
    rates.find_by(user_id: user.id, rating_id: id)
  end

  def value
    rates.where(up: true).count - rates.where(up: false).count
  end
end