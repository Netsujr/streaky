require "application_system_test_case"

class HabitsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      timezone: "America/Sao_Paulo"
    )
  end

  test "sign in, create habit, toggle check-in, and verify Turbo updates" do
    visit sign_in_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    assert_text "Welcome back"

    click_link "New Habit"

    fill_in "Name", with: "Drink Water"
    fill_in "Goal per week (days)", with: 7
    click_button "Create Habit"

    assert_text "Drink Water"

    habit_card = find("[id^='habit_']", match: :first)
    initial_streak_text = habit_card.find("p[id^='current-streak']").text

    today_button = habit_card.find("button", match: :first)
    today_button.click

    sleep 0.5

    habit_card = find("[id^='habit_']", match: :first)
    new_streak_text = habit_card.find("p[id^='current-streak']").text

    assert_not_equal initial_streak_text, new_streak_text
    assert_equal "1", new_streak_text
  end

  test "hold to confirm check-in works" do
    @habit = Habit.create!(
      user: @user,
      name: "Exercise",
      goal_per_week: 7,
      start_date: Date.today
    )

    visit sign_in_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_button "Sign In"

    habit_card = find("[id^='habit_']", match: :first)
    today_button = habit_card.find("button", match: :first)

    assert today_button.present?

    today_button.native.hold(600)

    sleep 0.5

    habit_card = find("[id^='habit_']", match: :first)
    streak_text = habit_card.find("p[id^='current-streak']").text
    assert_equal "1", streak_text
  end
end
