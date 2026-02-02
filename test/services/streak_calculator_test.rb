require "test_helper"

class StreakCalculatorTest < ActiveSupport::TestCase
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
      start_date: Date.today - 30.days
    )
  end

  test "calculates current streak correctly" do
    today = Date.today
    Checkin.create!(habit: @habit, user: @user, occurred_on: today)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 1.day)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 2.days)

    calculator = StreakCalculator.new(@habit)
    assert_equal 3, calculator.current_streak_days
  end

  test "returns zero when no checkins exist" do
    calculator = StreakCalculator.new(@habit)
    assert_equal 0, calculator.current_streak_days
  end

  test "handles gaps in streak correctly" do
    today = Date.today
    Checkin.create!(habit: @habit, user: @user, occurred_on: today)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 1.day)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 5.days)

    calculator = StreakCalculator.new(@habit)
    assert_equal 2, calculator.current_streak_days
  end

  test "calculates longest streak correctly" do
    today = Date.today
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 10.days)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 9.days)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 8.days)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 6.days)
    Checkin.create!(habit: @habit, user: @user, occurred_on: today - 5.days)

    calculator = StreakCalculator.new(@habit)
    assert_equal 3, calculator.longest_streak_days
  end

  test "calculates longest streak when all consecutive" do
    today = Date.today
    5.times do |i|
      Checkin.create!(habit: @habit, user: @user, occurred_on: today - i.days)
    end

    calculator = StreakCalculator.new(@habit)
    assert_equal 5, calculator.longest_streak_days
  end

  test "uses user timezone for today calculation" do
    user_utc = User.create!(
      name: "UTC User",
      email: "utc@example.com",
      password: "password123",
      password_confirmation: "password123",
      timezone: "UTC"
    )
    habit_utc = Habit.create!(
      user: user_utc,
      name: "UTC Habit",
      goal_per_week: 7,
      start_date: Date.today - 30.days
    )

    calculator = StreakCalculator.new(habit_utc, user_timezone: "UTC")
    today_utc = Time.use_zone("UTC") { Time.zone.today }

    Checkin.create!(habit: habit_utc, user: user_utc, occurred_on: today_utc)
    assert_equal 1, calculator.current_streak_days
  end

  test "handles timezone boundary edge case" do
    user_sp = User.create!(
      name: "SP User",
      email: "sp@example.com",
      password: "password123",
      password_confirmation: "password123",
      timezone: "America/Sao_Paulo"
    )
    habit_sp = Habit.create!(
      user: user_sp,
      name: "SP Habit",
      goal_per_week: 7,
      start_date: Date.today - 30.days
    )

    today_sp = Time.use_zone("America/Sao_Paulo") { Time.zone.today }
    yesterday_sp = today_sp - 1.day

    Checkin.create!(habit: habit_sp, user: user_sp, occurred_on: today_sp)
    Checkin.create!(habit: habit_sp, user: user_sp, occurred_on: yesterday_sp)

    calculator = StreakCalculator.new(habit_sp, user_timezone: "America/Sao_Paulo")
    assert_equal 2, calculator.current_streak_days
  end

end
