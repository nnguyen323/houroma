class User < ActiveRecord::Base
	searchkick text_start: [:username]
	has_many :activities, dependent: :destroy
	has_many :active_relationships, 	class_name: 	"Relationship",
																		foreign_key: 	"tracker_id",
																		dependent: 		:destroy
	has_many :passive_relationships, 	class_name: 	"Relationship",
																	 	foreign_key: 	"tracked_id",
																	 	dependent: 		:destroy
	has_many :tracking, through: :active_relationships,  source: :tracked
	has_many :trackers, through: :passive_relationships, source: :tracker
	has_many :nests, dependent: :destroy
	has_many :rates, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :passive_birds, 	class_name: "Bird",
														dependent: :destroy
	belongs_to :activity, class_name: "Activity",
												foreign_key: "active_id"

	mount_uploader :picture, PictureUploader
	attr_accessor :remember_token, :activation_token, :reset_token
	before_save :downcase_email
	before_save :downcase_username

	before_create :create_activation_digest
	before_save { self.email = email.downcase }
	VALID_USERNAME_REGEX = /\A[a-zA-Z0-9_]*\z/
	validates :username, presence: true, length: { minimum: 4, maximum: 20 }, 
											 format: { with: VALID_USERNAME_REGEX, message: "can only contain numbers, letters, and underscores"}, 
											 uniqueness: { case_sensitive: false }

	VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, 
	                  format: { with: VALID_EMAIL_REGEX }, 
	                  uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
	validate :picture_size

	#change id to username by overriding this thing
  def to_param
   username
  end

  #control what data is indexed with the search_data method chartkick.
  def search_data
    as_json only: [:username]
  end

	# Returns the hash digest of the given string.
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
	                                                  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	#generate and return a random token
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(self.remember_token))
	end

	def authenticated?(attribute,token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	# activate an account!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	# send happy email
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now	
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
		tracking_ids = "SELECT tracked_id FROM relationships
										WHERE tracker_id = :user_id"
		Activity.where("user_id IN (#{tracking_ids}) OR user_id = :user_id", user_id: id)
	end

	#track head admin so you can see greetings and stuff
	def track_admin
		user = User.find_by_username("houroma")
		if user
			track user
		end
	end

	#track a user
	def track(other_user)
		active_relationships.create(tracked_id: other_user.id)
	end

	#untrack a user
	def untrack(other_user)
		active_relationships.find_by(tracked_id: other_user.id).destroy
	end

	#return true if the current user is tracking the other user
	def tracking?(other_user)
		tracking.include?(other_user)
	end

	private

		def downcase_email
			self.email = email.downcase
		end
		def downcase_username
			self.username = username.downcase
		end

		# Creates and assigns the activation token and digest.
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end

  	# Validates that size!
  	def picture_size
  		if picture.size > 5.megabytes
  			errors.add(:picture, "should be less than 5MB")
  		end
  	end
end
