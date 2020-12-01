Dokno.configure do |config|
  config.tag_whitelist          = Dokno::Config::TAG_WHITELIST
  config.attr_whitelist         = Dokno::Config::ATTR_WHITELIST

  # To restrict Dokno data modification and include indentifying information
  # in change log entries, provide the appropriate user values for your app below.
  #   (String) app_user_object
  #   (Symbol) app_user_auth_method
  #   (Symbol) app_user_name_method

  config.app_user_object      = 'current_user'
  config.app_user_auth_method = :admin?
  config.app_user_name_method = :name
end
