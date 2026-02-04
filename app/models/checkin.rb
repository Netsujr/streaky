# one checkin = user checked in for a habit on a given date. unique per habit + occurred_on.
class Checkin < ApplicationRecord
  belongs_to :habit
  belongs_to :user

  validates :occurred_on, presence: true
  validates :occurred_on, uniqueness: { scope: :habit_id }

  scope :for_date_range, ->(start_date, end_date) { where(occurred_on: start_date..end_date) }
  scope :for_habit, ->(habit) { where(habit: habit) }
end
