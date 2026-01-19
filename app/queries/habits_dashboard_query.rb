class HabitsDashboardQuery
  attr_reader :user, :today_date

  def initialize(user)
    @user = user
    @today_date = today_in_user_timezone
  end

  def call
    {
      habits: habits_with_stats,
      today_completion_count: today_completion_count,
      week_start_date: week_start_date,
      week_end_date: today_date
    }
  end

  private

  def habits_with_stats
    active_habits.map do |habit|
      calculator = StreakCalculator.new(habit, reference_date: today_date, user_timezone: user.timezone)
      checkins_for_habit = checkins_by_habit_id[habit.id] || []

      {
        habit: habit,
        current_streak_days: calculator.current_streak_days,
        longest_streak_days: calculator.longest_streak_days,
        completion_rate_last_7_days: calculator.completion_rate_last_7_days,
        checked_in_dates: checkins_for_habit.map(&:occurred_on).to_set
      }
    end
  end

  def active_habits
    @active_habits ||= user.habits.active.includes(:checkins).order(created_at: :desc)
  end

  def week_start_date
    @week_start_date ||= today_date - 6.days
  end

  def checkins_by_habit_id
    @checkins_by_habit_id ||= Checkin.where(habit: active_habits)
                                     .where(occurred_on: week_start_date..today_date)
                                     .includes(:habit)
                                     .group_by(&:habit_id)
  end

  def today_completion_count
    Checkin.where(user: user, occurred_on: today_date).count
  end

  def today_in_user_timezone
    Time.use_zone(user.timezone) { Time.zone.today }
  end
end
