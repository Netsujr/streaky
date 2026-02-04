# runs weekly on mondays (cron). for each user with weekly summary on, builds last weeks
# stats per habit (streaks, checkin count, at-risk) and sends one summary email.
class WeeklySummaryJob < ApplicationJob
  queue_as :default

  def perform
    User.where(weekly_summary_enabled: true).find_each do |user|
      send_weekly_summary(user)
    end
  end

  def send_weekly_summary(user)
    today = Time.use_zone(user.timezone) { Time.zone.today }
    week_start = today.beginning_of_week(:monday) - 7.days
    week_end = today.beginning_of_week(:monday) - 1.day

    habits_with_stats = user.habits.active.map do |habit|
      checkins_count = habit.checkins.where(occurred_on: week_start..week_end).count
      calculator = StreakCalculator.new(habit, reference_date: today, user_timezone: user.timezone)

      at_risk = calculator.current_streak_days == 0 && checkins_count == 0

      {
        habit: habit,
        current_streak_days: calculator.current_streak_days,
        longest_streak_days: calculator.longest_streak_days,
        checkins_count: checkins_count,
        at_risk: at_risk
      }
    end

    if habits_with_stats.any?
      WeeklySummaryMailer.summary(user, {
        habits: habits_with_stats,
        week_start: week_start,
        week_end: week_end
      }).deliver_now
    end
  end
end
