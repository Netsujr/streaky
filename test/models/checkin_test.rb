require "test_helper"

class CheckinTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      timezone: "America/Sao_Paulo"
    )
    @habit = Habit.create!(
      user: @user,
      name: "Test Habit",
      goal_per_week: 7,
      start_date: Date.today
    )
  end

  test "prevents duplicate checkins for same habit and date" do
    date = Date.today
    Checkin.create!(habit: @habit, user: @user, occurred_on: date)

    duplicate = Checkin.new(habit: @habit, user: @user, occurred_on: date)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:occurred_on], "has already been taken"
  end

  test "allows checkins for same date on different habits" do
    habit2 = Habit.create!(
      user: @user,
      name: "Another Habit",
      goal_per_week: 5,
      start_date: Date.today
    )
    date = Date.today

    Checkin.create!(habit: @habit, user: @user, occurred_on: date)
    checkin2 = Checkin.create!(habit: habit2, user: @user, occurred_on: date)

    assert checkin2.persisted?
  end

  test "toggle creates checkin when none exists" do
    date = Date.today
    assert_difference "Checkin.count", 1 do
      Checkin.find_or_create_by!(habit: @habit, user: @user, occurred_on: date)
    end
  end

  test "toggle is idempotent" do
    date = Date.today
    Checkin.find_or_create_by!(habit: @habit, user: @user, occurred_on: date)

    assert_no_difference "Checkin.count" do
      Checkin.find_or_create_by!(habit: @habit, user: @user, occurred_on: date)
    end
  end

  test "can destroy and recreate checkin" do
    date = Date.today
    checkin = Checkin.create!(habit: @habit, user: @user, occurred_on: date)
    assert checkin.persisted?

    checkin.destroy
    assert checkin.destroyed?

    new_checkin = Checkin.create!(habit: @habit, user: @user, occurred_on: date)
    assert new_checkin.persisted?
  end
end
