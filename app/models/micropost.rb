class Micropost < ActiveRecord::Base
  belongs_to :user
  # Default order elements are retrieved from db
  default_scope -> { order(created_at: :desc) }
  # Image uploader mount (attribute, ClassName).
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  # Custom validation uses validate instead of validates.
  validate  :picture_size

  private
    # Validates the file size of the uploaded pictures.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB.")
      end
    end
end
