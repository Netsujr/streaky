# frozen_string_literal: true

class StreakCalculator
  # finds the longest run of consecutive dates in the set (all time best streak).
  class LongestStreak
    def self.call(dates_set)
      new(dates_set).call
    end

    def initialize(dates_set)
      @sorted_dates = dates_set.sort
    end

    def call
      return 0 if sorted_dates.empty?

      max_consecutive
    end

    private

    attr_reader :sorted_dates

    def max_consecutive
      longest = 0
      current = 0

      sorted_dates.each_with_index do |date, index|
        if index.zero? || sorted_dates[index - 1] == date - 1.day
          current += 1
          longest = current if current > longest
        else
          current = 1
        end
      end

      longest
    end
  end
end
