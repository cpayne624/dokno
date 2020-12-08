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
        eval sanitized_user_obj_string
      }.call

    rescue NameError => _e
      nil
    end

    def sanitized_user_obj_string
      Dokno.config.app_user_object.to_s.split(/\b/).first
    end

    def username
      user&.send(Dokno.config.app_user_name_method.to_sym).to_s
    end

    def can_edit?
      # Allow editing by default if host app user object is not configured
      return true  unless sanitized_user_obj_string.present?
      return false unless user.respond_to? Dokno.config.app_user_auth_method.to_sym

      user.send(Dokno.config.app_user_auth_method.to_sym)
    end

    def authorize
      return redirect_to root_path unless can_edit?
    end
  end
end
