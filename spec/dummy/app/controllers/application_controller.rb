class ApplicationController < ActionController::Base
  include ApplicationHelper

  helper_method :current_user

  private

  # See spec/dummy/app/lib/user.rb for mocked User model for authorization testing
  def current_user
    @current_user ||= User.new
  end
end
