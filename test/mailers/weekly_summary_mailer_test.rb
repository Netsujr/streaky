require "test_helper"

class WeeklySummaryMailerTest < ActionMailer::TestCase
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
    @week_start = Date.today.beginning_of_week(:monday) - 7.days
    @week_end = Date.today.beginning_of_week(:monday) - 1.day
  end

  test "summary" do
    summary_data = {
      habits: [{
        habit: @habit,
        current_streak_days: 5,
        longest_streak_days: 7,
        checkins_count: 5,
        at_risk: false
      }],
      week_start: @week_start,
      week_end: @week_end
    }
    mail = WeeklySummaryMailer.summary(@user, summary_data)
    assert_equal "Your Weekly Habit Summary", mail.subject
    assert_equal [@user.email], mail.to
    assert_match @user.name, mail.body.encoded
    assert_match @habit.name, mail.body.encoded
  end
end
