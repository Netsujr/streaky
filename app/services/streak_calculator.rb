# frozen_string_literal: true

# Facade for streak metrics. Delegates to single-responsibility components.
# See: StreakCalculator::CheckedInDates, CurrentStreak, LongestStreak.
class StreakCalculator
  attr_reader :habit, :reference_date, :user_timezone

  def initialize(habit, reference_date: nil, user_timezone: nil)
    @habit = habit
    @user_timezone = user_timezone || habit.user.timezone
    @reference_date = reference_date || today_in_timezone
  end

  def current_streak_days
    CurrentStreak.call(checked_in_dates, reference_date)
  end

  def longest_streak_days
    LongestStreak.call(checked_in_dates)
  end

  def checked_in_dates_set(last_n_days: 7)
    date_loader.in_range(last_n_days: last_n_days)
  end

  def checked_in_dates
    date_loader.all
  end

  private

  def date_loader
    @date_loader ||= CheckedInDates.new(
      habit,
      reference_date: reference_date,
      user_timezone: user_timezone
    )
  end

  def today_in_timezone
    Time.use_zone(user_timezone) { Time.zone.today }
  end
end
