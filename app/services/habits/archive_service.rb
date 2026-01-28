# frozen_string_literal: true

module Habits
  # Archives or restores a habit. Returns { archived: true|false, notice: String }.
  # Controller chooses redirect path based on :archived.
  class ArchiveService
    def self.call(habit)
      new(habit).call
    end

    def initialize(habit)
      @habit = habit
    end

    def call
      if habit.archived?
        unarchive
      else
        archive
      end
    end

    private

    attr_reader :habit

    def archive
      habit.update_column(:archived_at, Time.current)
      habit.reload
      { archived: true, notice: "Habit archived!" }
    end

    def unarchive
      habit.update_column(:archived_at, nil)
      habit.reload
      { archived: false, notice: "Habit restored!" }
    end
  end
end
