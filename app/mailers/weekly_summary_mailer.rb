class WeeklySummaryMailer < ApplicationMailer
  def summary(user, summary_data)
    @user = user
    @habits = summary_data[:habits]
    @week_start = summary_data[:week_start]
    @week_end = summary_data[:week_end]

    mail to: user.email, subject: "Your Weekly Habit Summary"
  end
end
