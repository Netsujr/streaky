class ReminderMailer < ApplicationMailer
  def reminder(user, habits)
    @user = user
    @habits = habits
    @today = Time.use_zone(user.timezone) { Time.zone.today }

    mail to: user.email, subject: "Reminder: Check in on your habits today!"
  end
end
