# frozen_string_literal: true

class StreakCalculator
  # Computes completion rate (0–100) for last N days, respecting habit start_date.
  class CompletionRate
    def self.call(habit, dates_in_range, reference_date, last_n_days: 7)
      new(habit, dates_in_range, reference_date, last_n_days: last_n_days).call
    end

    def initialize(habit, dates_in_range, reference_date, last_n_days: 7)
      @habit = habit
      @dates_in_range = dates_in_range
      @reference_date = reference_date
      @last_n_days = last_n_days
    end

    def call
      return 0 if dates_in_range.empty?

      days_in_range = effective_days_in_range
      return 0 if days_in_range.zero?

      (dates_in_range.count.to_f / days_in_range * 100).to_i
    end

    private

    attr_reader :habit, :dates_in_range, :reference_date, :last_n_days

    def effective_days_in_range
      start_date = reference_date - (last_n_days - 1).days
      effective_start = [habit.start_date, start_date].max
      (effective_start..reference_date).count
    end
  end
end
