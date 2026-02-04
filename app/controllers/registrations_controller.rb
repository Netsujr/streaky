# sign up - new user form and create. uses auth layout, no login required for these actions (skip auth)
class RegistrationsController < ApplicationController
  layout "authentication"
  skip_before_action :require_authentication, only: [:new, :create]
  before_action :skip_authentication, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome to Streaky, #{@user.name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :timezone)
  end
end
