class User < ApplicationRecord
  SIGN_UP_REQUIRE_ATTRIBUTES = %i(name email password
password_confirmation).freeze
  has_secure_password
  before_save :downcase_email
  attr_accessor :remember_token

  validates :name, presence: true,
            length: {maximum: Settings.sign_up.max_name_length}

  validates :email,
            presence: true,
            length: {maximum: Settings.sign_up.max_email_length},
            format: {with: Settings.sign_up.email_regex},
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length: {minimum: Settings.sign_up.min_password_length}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
