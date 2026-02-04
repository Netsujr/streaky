# user settings page - timezone and email prefs (weekly summary, reminders). update saves and redirects
class SettingsController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(settings_params)
      redirect_to settings_path, notice: "Settings updated!"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(:timezone, :weekly_summary_enabled, :reminders_enabled)
  end
end
