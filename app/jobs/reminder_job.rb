class ReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.where(reminders_enabled: true).find_each do |user|
      today = Time.use_zone(user.timezone) { Time.zone.today }

      habits_not_checked_in = user.habits.active.select do |habit|
        !habit.checkins.exists?(occurred_on: today)
      end

      if habits_not_checked_in.any?
        ReminderMailer.reminder(user, habits_not_checked_in).deliver_now
      end
    end
  end
end
