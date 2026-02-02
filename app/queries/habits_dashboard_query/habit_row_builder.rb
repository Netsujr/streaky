# frozen_string_literal: true

class HabitsDashboardQuery
  # Builds the stats hash for a single habit. One job: one row of dashboard data.
  class HabitRowBuilder
    def self.call(habit, reference_date:, user_timezone:, checkins_for_habit:)
      new(habit, reference_date: reference_date, user_timezone: user_timezone, checkins_for_habit: checkins_for_habit).call
    end

    def initialize(habit, reference_date:, user_timezone:, checkins_for_habit:)
      @habit = habit
      @reference_date = reference_date
      @user_timezone = user_timezone
      @checkins_for_habit = checkins_for_habit
    end

    def call
      {
        habit: habit,
        current_streak_days: calculator.current_streak_days,
        longest_streak_days: calculator.longest_streak_days,
        checked_in_dates: checked_in_dates_set
      }
    end

    private

    attr_reader :habit, :reference_date, :user_timezone, :checkins_for_habit

    def calculator
      @calculator ||= StreakCalculator.new(
        habit,
        reference_date: reference_date,
        user_timezone: user_timezone
      )
    end

    def checked_in_dates_set
      checkins_for_habit.map(&:occurred_on).to_set
    end
  end
end
