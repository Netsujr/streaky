# frozen_string_literal: true

# builds the main dashboard payload: list of habits with streak/checkin stats, week range, today completion count.
# one query for habits + checkins, then habit row builder per habit so we dont n+1.
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
      checkins_for_habit = checkins_by_habit_id[habit.id] || []
      HabitRowBuilder.call(
        habit,
        reference_date: today_date,
        user_timezone: user.timezone,
        checkins_for_habit: checkins_for_habit
      )
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
