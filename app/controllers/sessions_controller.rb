class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]
  before_action :skip_authentication, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome back, #{@user.name}!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to sign_in_path, notice: "Signed out successfully"
  end
end
