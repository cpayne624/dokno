Dokno.configure do |config|
  config.tag_whitelist          = Dokno::Config::TAG_WHITELIST
  config.attr_whitelist         = Dokno::Config::ATTR_WHITELIST

  # To restrict Dokno data modification and include indentifying information
  # in change log entries, provide the appropriate user values for your app below.
  config.app_user_object      = 'current_user'
  config.app_user_auth_method = :admin?
  config.app_user_name_method = :name
end
