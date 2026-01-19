class HabitsController < ApplicationController
  before_action :set_habit, only: [:show, :edit, :update, :destroy, :archive]

  def index
    @habits = current_user.habits.active.order(created_at: :desc)
  end

  def show
  end

  def new
    @habit = current_user.habits.build
  end

  def create
    @habit = current_user.habits.build(habit_params)

    if @habit.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Habit created!" }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @habit.update(habit_params)
      respond_to do |format|
        format.html { redirect_to @habit, notice: "Habit updated!" }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    redirect_to root_path, notice: "Habit deleted!"
  end

  def archive
    @habit.archive!
    redirect_to root_path, notice: "Habit archived!"
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:name, :goal_per_week, :start_date, :color)
  end
end
