require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
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

  test "reminder" do
    mail = ReminderMailer.reminder(@user, [@habit])
    assert_equal "Reminder: Check in on your habits today!", mail.subject
    assert_equal [@user.email], mail.to
    assert_match @user.name, mail.body.encoded
    assert_match @habit.name, mail.body.encoded
  end
end
