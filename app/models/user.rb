class User < ActiveRecord::Base
  # Establish dependency, destroy associated microposts when user is deleted
  has_many :microposts, dependent: :destroy
  # ActiveRelationships is a custom name for class Relationship.
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy

  # PassiveRelationships is the reverse and uses the same table.
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  # A user follows others through relationships.
  # Default is :followed, now it's mapped to :following.
  has_many :following, through: :active_relationships, source: :followed

  # A user has many followers through passive relationships.
  has_many :followers, through: :passive_relationships, source: :follower
  
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email
  # Create activation token before creating a User
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  # has_secure_password prevents empty passwords on user signup
  # allow_nil: true is used for edit page
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Class method User.digest
  # Returns the hex digest of a given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  # Parameter attribute generalizes the method to accept any type,
  # e.g. activation_digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends the password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed.
  def feed
    # "?" ensures id is being escaped.
    #Micropost.where("user_id = ?", id)
    # Includes feeds from following users. Inefficient when following_ids is large.
    # Creates a large array.
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # Optimize SQL with subselects.
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id= :user_id"
    Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
  end 

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private
    # Converst an email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
