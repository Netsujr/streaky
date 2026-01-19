class DashboardController < ApplicationController
  def show
    @dashboard_data = HabitsDashboardQuery.new(current_user).call
  end
end
