# frozen_string_literal: true

module Checkins
  # Toggles a check-in for a habit on a given date: creates or destroys.
  # Returns { checkin:, action: :created | :destroyed }.
  class ToggleService
    def self.call(habit:, user:, date:)
      new(habit: habit, user: user, date: date).call
    end

    def initialize(habit:, user:, date:)
      @habit = habit
      @user = user
      @date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    end

    def call
      existing = find_checkin
      if existing
        destroy_checkin(existing)
      else
        create_checkin
      end
    end

    private

    attr_reader :habit, :user, :date

    def find_checkin
      Checkin.find_by(habit: habit, occurred_on: date)
    end

    def destroy_checkin(checkin)
      checkin.destroy!
      { checkin: checkin, action: :destroyed }
    end

    def create_checkin
      checkin = Checkin.create!(habit: habit, user: user, occurred_on: date)
      { checkin: checkin, action: :created }
    rescue ActiveRecord::RecordInvalid => e
      handle_duplicate_on_create(e)
    end

    def handle_duplicate_on_create(error)
      raise error unless duplicate_occurred_on?(error)

      existing = Checkin.find_by(habit: habit, occurred_on: date)
      existing&.destroy!
      create_checkin
    end

    def duplicate_occurred_on?(error)
      error.record.errors[:occurred_on]&.include?("has already been taken")
    end
  end
end
