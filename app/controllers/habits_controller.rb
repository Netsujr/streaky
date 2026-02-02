# frozen_string_literal: true

class HabitsController < ApplicationController
  include HabitLoading

  before_action :set_habit, only: [:show, :edit, :update, :destroy, :archive, :calendar]

  def index
    @habits = current_user.habits.active.order(created_at: :desc)
  end

  def archived
    @habits = current_user.habits.archived.order(archived_at: :desc)
  end

  def show
  end

  def edit
    respond_to_habit_form
  end

  def new
    @habit = current_user.habits.build
    respond_to_habit_form
  end

  def create
    @habit = current_user.habits.build(habit_params)

    if @habit.save
      @dashboard_data = HabitsDashboardQuery.new(current_user).call
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Habit created!" }
        format.turbo_stream
      end
    else
      respond_to_habit_form_with_errors(:new)
    end
  end

  def update
    if @habit.update(habit_params)
      respond_to do |format|
        format.html { redirect_to @habit, notice: "Habit updated!" }
        format.turbo_stream
      end
    else
      respond_to_habit_form_with_errors(:edit)
    end
  end

  def destroy
    @habit.destroy
    redirect_to root_path, notice: "Habit deleted!"
  end

  def archive
    result = Habits::ArchiveService.call(@habit)
    redirect_path = result[:archived] ? (request.referer || root_path) : habits_path
    redirect_to redirect_path, notice: result[:notice]
  end

  def calendar
    today = Time.use_zone(current_user.timezone) { Time.zone.today }
    @month = begin
      params[:month].present? ? Date.parse(params[:month]) : today
    rescue ArgumentError
      today
    end
    @month = @month.beginning_of_month
    @checked_dates = @habit.checkins.pluck(:occurred_on).to_set
    respond_to do |format|
      # full layout so Turbo Frame requests get styled document; Turbo extracts the frame
      format.html { render :calendar }
      format.turbo_stream
    end
  end

  private

  def respond_to_habit_form
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def respond_to_habit_form_with_errors(template)
    respond_to do |format|
      format.html { render template, status: :unprocessable_entity }
      format.turbo_stream { render template, status: :unprocessable_entity }
    end
  end
end
