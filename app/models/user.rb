class User < ApplicationRecord
  has_secure_password

  has_many :habits, dependent: :destroy
  has_many :checkins, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :timezone, presence: true

  before_validation :set_default_timezone

  private

  def set_default_timezone
    self.timezone ||= "America/Sao_Paulo"
  end
end
