# frozen_string_literal: true

class StreakCalculator
  # counts consecutive days going backward from reference_date (e.g. today). thats the "current streak".
  class CurrentStreak
    def self.call(dates_set, reference_date)
      new(dates_set, reference_date).call
    end

    def initialize(dates_set, reference_date)
      @dates_set = dates_set
      @reference_date = reference_date
    end

    def call
      return 0 if dates_set.empty?

      count_consecutive_backward
    end

    private

    attr_reader :dates_set, :reference_date

    def count_consecutive_backward
      days = 0
      date = reference_date

      while dates_set.include?(date)
        days += 1
        date = date - 1.day
      end

      days
    end
  end
end
