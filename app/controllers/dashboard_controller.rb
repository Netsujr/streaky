# main dashboard, loads all the habit cards and last 7 days data for teh current user
class DashboardController < ApplicationController
  def show
    @dashboard_data = HabitsDashboardQuery.new(current_user).call
  end
end
