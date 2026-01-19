class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_authentication

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_authentication
    redirect_to sign_in_path unless current_user
  end

  def skip_authentication
    redirect_to root_path if current_user
  end

  helper_method :current_user
end
