# frozen_string_literal: true

class StreakCalculator
  # loads checkin dates for a habit from the db, scoped to reference date / timezone. used by current/longest streak.
  class CheckedInDates
    def initialize(habit, reference_date:, user_timezone:)
      @habit = habit
      @reference_date = reference_date
      @user_timezone = user_timezone
    end

    def all
      @all ||= load_dates_up_to_reference
    end

    def in_range(last_n_days:)
      start_date = reference_date - (last_n_days - 1).days
      raw = Checkin.where(habit: habit)
                   .where("occurred_on >= ?", start_date)
                   .pluck(:occurred_on)
                   .to_set
      Set.new((start_date..reference_date).select { |d| raw.include?(d) })
    end

    private

    attr_reader :habit, :reference_date, :user_timezone

    def load_dates_up_to_reference
      Checkin.where(habit: habit)
             .where("occurred_on <= ?", reference_date)
             .pluck(:occurred_on)
             .to_set
    end
  end
end
