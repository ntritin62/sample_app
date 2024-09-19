class User < ApplicationRecord
  SIGN_UP_REQUIRE_ATTRIBUTES = %i(name email password
password_confirmation).freeze
  has_secure_password
  before_save :downcase_email

  attr_accessor :remember_token, :activation_token

  before_create :create_activation_digest

  validates :name, presence: true,
            length: {maximum: Settings.sign_up.max_name_length}

  validates :email,
            presence: true,
            length: {maximum: Settings.sign_up.max_email_length},
            format: {with: Settings.sign_up.email_regex},
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length: {minimum: Settings.sign_up.min_password_length},
            allow_nil: true

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

  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def session_token
    remember_digest || remember
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
