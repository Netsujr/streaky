# frozen_string_literal: true

# loads @habit for current user and permits habit paramaters for create/update
module HabitLoading
  extend ActiveSupport::Concern

  PERMITTED_HABIT_PARAMS = %i[name goal_per_week start_date color].freeze

  private

  def set_habit
    @habit = Habit.where(user: current_user).find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(PERMITTED_HABIT_PARAMS)
  end
end
