class StreakCalculator
  attr_reader :habit, :reference_date, :user_timezone

  def initialize(habit, reference_date: nil, user_timezone: nil)
    @habit = habit
    @user_timezone = user_timezone || habit.user.timezone
    @reference_date = reference_date || today_in_timezone
  end

  def current_streak_days
    return 0 if checked_in_dates.empty?

    days = 0
    date = reference_date

    while checked_in_dates.include?(date)
      days += 1
      date = date - 1.day
    end

    days
  end

  def longest_streak_days
    return 0 if checked_in_dates.empty?

    longest = 0
    current = 0
    sorted_dates = checked_in_dates.sort

    sorted_dates.each_with_index do |date, index|
      if index == 0 || sorted_dates[index - 1] == date - 1.day
        current += 1
        longest = current if current > longest
      else
        current = 1
      end
    end

    longest
  end

  def checked_in_dates_set(last_n_days: 7)
    start_date = reference_date - (last_n_days - 1).days
    checkin_dates = Checkin.where(habit: habit)
                           .where("occurred_on >= ?", start_date)
                           .pluck(:occurred_on)
                           .to_set
    Set.new((start_date..reference_date).select { |d| checkin_dates.include?(d) })
  end

  def checked_in_dates
    @checked_in_dates ||= Checkin.where(habit: habit)
                                  .where("occurred_on <= ?", reference_date)
                                  .pluck(:occurred_on)
                                  .to_set
  end

  def completion_rate_last_7_days
    dates = checked_in_dates_set(last_n_days: 7)
    return 0.0 if dates.empty?

    start_date = reference_date - 6.days
    habit_start = habit.start_date
    effective_start = habit_start > start_date ? habit_start : start_date
    days_in_range = (effective_start..reference_date).count

    return 0.0 if days_in_range.zero?

    (dates.count.to_f / days_in_range * 100).round(1)
  end

  private

  def today_in_timezone
    Time.use_zone(user_timezone) { Time.zone.today }
  end
end
