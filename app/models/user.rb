class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  attr_accessor :remember_token
  before_save :downcase_email

  validates :email, presence: true, length: {minimum: 20, maximum: 40},
  format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  validates :name, presence: true, length: {maximum: 10}
  has_secure_password

  validates :password, presence: true, length: {minimum: 6}, if: :password

  #private

  def downcase_email
    self.email.downcase!
  end

  def User.digest string
    cost =  if ActiveModel::SecurePassword.min_cost
              BCrypt::Engine::MIN_COST
            else
              BCrypt::Engine.cost
            end
    BCrypt::Password.create string, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    if remember_digest.nil?
      false
    else
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  end

  # Forget a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
