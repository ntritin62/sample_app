class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [Settings.img_resize_limit,
                       Settings.img_resize_limit]
  end
  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image,
            content_type: {in: Settings.img_accept_format.split(",")},
            size:         {less_than: Settings.max_upload_img_size.megabytes}

  scope :newest, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
  CREATE_PARAMS = %i(content image).freeze
end
