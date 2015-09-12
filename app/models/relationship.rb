class Relationship < ActiveRecord::Base
  # Becomes follower_id and followed_id, referencing a user_id.
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true 
end
