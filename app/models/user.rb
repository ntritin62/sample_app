class User < ApplicationRecord
  SIGN_UP_REQUIRE_ATTRIBUTES = %i(name email password
password_confirmation).freeze
  has_secure_password
  before_save :downcase_email

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
  end

  private
  def downcase_email
    email.downcase!
  end
end
