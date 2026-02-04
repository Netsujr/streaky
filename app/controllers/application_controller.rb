# frozen_string_literal: true

# base controller, makes sure user is logged in for all actions
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Authentication

  before_action :require_authentication
end
