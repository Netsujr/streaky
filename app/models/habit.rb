class Habit < ApplicationRecord
  belongs_to :user
  has_many :checkins, dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validates :goal_per_week, presence: true, inclusion: { in: 1..7 }
  validates :start_date, presence: true
  validates :color, inclusion: { in: %w[blue green purple red orange yellow pink indigo], allow_nil: true }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archived?
    archived_at.present?
  end

  def archive!
    update(archived_at: Time.current)
  end

  def unarchive!
    update(archived_at: nil)
  end
end
