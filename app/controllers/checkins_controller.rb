# frozen_string_literal: true

# handels toggling a checkin on/off for a given date, returns turbo stream to updat the ui
class CheckinsController < ApplicationController
  before_action :set_habit

  def toggle
    date = parse_toggle_date
    result = Checkins::ToggleService.call(habit: @habit, user: current_user, date: date)

    @checkin = result[:checkin]
    @action = result[:action]
    @dashboard_data = HabitsDashboardQuery.new(current_user).call

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end

  def parse_toggle_date
    raw = params[:date] || today_in_user_timezone
    Date.parse(raw.to_s)
  end

  def today_in_user_timezone
    Time.use_zone(current_user.timezone) { Time.zone.today }
  end
end
