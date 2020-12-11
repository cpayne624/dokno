Dokno.configure do |config|
  # To control the permitted HTML tags and attributes within articles,
  # uncomment and change the defaults.
  #   (Enumerable) tag_whitelist
  #   (Enumerable) attr_whitelist
  # config.tag_whitelist         = %w[code img h1 h2 h3 h4 h5 h6 a em u i b strong ol ul li table thead tbody tfoot tr th td blockquote hr br p]
  # config.attr_whitelist        = %w[src alt title href target]

  # To restrict Dokno data modification and include indentifying information
  # in change log entries, provide the appropriate user values for your app below.
  #   (String) app_user_object
  #   (Symbol) app_user_auth_method
  #   (Symbol) app_user_name_method
  # config.app_user_object       = 'current_user'
  # config.app_user_auth_method  = :admin?
  # config.app_user_name_method  = :name

  # To control the amount of time before a created/updated article is flagged
  # for accuracy/relevance review, uncomment and change the default.
  #   (ActiveSupport::Duration) article_review_period
  # config.article_review_period = 1.year

  # To control the number of days prior to an article being up for review
  # that users should be prompted to re-review, uncomment and change the default.
  #   (Integer) article_review_prompt_days
  # config.article_review_prompt_days = 30
end
