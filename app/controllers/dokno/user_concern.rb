module Dokno
  module UserConcern
    extend ActiveSupport::Concern

    included do
      helper_method :user, :username, :can_edit?
    end

    def user
      # Attempt to eval the currently signed in 'user' object from the host app
      proc {
        $safe = 1
        eval Dokno::Config::APP_USER_OBJECT
      }.call

    rescue NameError => _e
      nil
    end

    def username
      user&.send(Dokno::Config::APP_USER_NAME_METHOD.to_sym).to_s
    end

    def can_edit?
      # Allow editing by default if host app user object is not configured
      return true  unless user.present?
      return false unless user.respond_to? Dokno::Config::APP_USER_AUTH_METHOD.to_sym

      user.send(Dokno::Config::APP_USER_AUTH_METHOD.to_sym)
    end

    def authorize
      return redirect_to root_path unless can_edit?
    end
  end
end
