class CheckinsController < ApplicationController
  before_action :set_habit

  def toggle
    date_param = params[:date] || today_in_user_timezone
    date = Date.parse(date_param.to_s)

    checkin = Checkin.find_by(habit: @habit, occurred_on: date)

    if checkin
      checkin.destroy
      action = :destroyed
    else
      checkin = Checkin.create!(habit: @habit, user: current_user, occurred_on: date)
      action = :created
    end

    calculator = StreakCalculator.new(@habit, reference_date: today_in_user_timezone, user_timezone: current_user.timezone)
    @dashboard_data = HabitsDashboardQuery.new(current_user).call

    respond_to do |format|
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid => e
    if e.record.errors[:occurred_on].include?("has already been taken")
      existing = Checkin.find_by(habit: @habit, occurred_on: date)
      existing&.destroy
      retry
    else
      head :unprocessable_entity
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end

  def today_in_user_timezone
    Time.use_zone(current_user.timezone) { Time.zone.today }
  end
end
