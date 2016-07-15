class Action < ActiveRecord::Base
  searchkick text_start: [:content]
  has_many :activities, dependent: :destroy
  has_many :nests, dependent: :destroy

  VALID_CONTENT_REGEX = /\A[a-zA-z]\w*\z/
  VALID_FIRST_CHARACTER_REGEX = /\A[a-zA-Z]\z/
  validates :content, presence: true, format:
   { with: VALID_CONTENT_REGEX, message: "hashtags must start with a letter" }
  validates_length_of :content, maximum: 199, message: "for hashtags must be 200 or less characters"
  before_save :downcase_content
  def search_data
    as_json only: [:content]
  end

  def feed
    Activity.where("action_id = ?", id).limit(20).order("created_at DESC")
  end

  def top_new
    Activity.joins(rating: :rates)
      .group("activities.id")
      .where("activities.action_id = ? AND activities.created_at > ?", id, 48.hours.ago)
      .select("activities.*")
      .having("SUM(CASE WHEN rates.up THEN 1
                 ELSE -1 END) > 0")
      .reorder("SUM(CASE WHEN rates.up THEN 1
                 ELSE -1 END) DESC")
      .limit(90)
  end 

  def all_time
    activities.joins(rating: :rates)
      .group("activities.id")
      .select("activities.*")
      .having("SUM(CASE WHEN rates.up THEN 1
                 ELSE -1 END) > 0")
      .reorder("SUM(CASE WHEN rates.up THEN 1
                 ELSE -1 END) DESC")
      .limit(90)
  end

  def active
    activities.where("activities.finished_at IS NULL")      
  end

  def live_users
    activities.where("finished_at IS NULL").count
  end

  private

    def downcase_content
      self.content = content.downcase
    end

end