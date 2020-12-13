module Dokno
  module Error
    class Config < StandardError; end
  end

  def self.configure
    yield config
    config.validate
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    # Dokno configuration options
    #
    # app_name (String)
    #   Host app name for display within the mounted dashboard
    # tag_whitelist (Enumerable)
    #   Determines which HTML tags are allowed in Article markdown
    # attr_whitelist (Enumerable)
    #   Determines which HTML attributes are allowed in Article markdown
    # app_user_object (String)
    #   Host app's user object
    # app_user_auth_method (Symbol)
    #   Host app's user object method to be used for edit authorization.
    #   Should return boolean
    # app_user_name_method (Symbol)
    #   Host app's user object method that returns the authenticated user's name or other
    #   identifier that will be included in change log events.
    #   Should return a string
    # article_review_period (ActiveSupport::Duration)
    #   The amount of time before articles should be reviewed for accuracy/relevance
    # article_review_prompt_days (Integer)
    #   The number of days prior to an article being up for review that users should be prompted

    attr_accessor :app_name
    attr_accessor :tag_whitelist
    attr_accessor :attr_whitelist
    attr_accessor :app_user_object
    attr_accessor :app_user_auth_method
    attr_accessor :app_user_name_method
    attr_accessor :article_review_period
    attr_accessor :article_review_prompt_days

    # Defaults
    TAG_WHITELIST              = %w[code img h1 h2 h3 h4 h5 h6 a em u i b strong ol ul li table thead tbody tfoot tr th td blockquote hr br p]
    ATTR_WHITELIST             = %w[src alt title href target]
    APP_USER_OBJECT            = 'current_user'
    APP_USER_AUTH_METHOD       = :admin?
    APP_USER_NAME_METHOD       = :name
    ARTICLE_REVIEW_PERIOD      = 1.year
    ARTICLE_REVIEW_PROMPT_DAYS = 30

    def initialize
      self.app_name                   = Rails.application.class.module_parent.name.underscore.humanize.upcase
      self.tag_whitelist              = TAG_WHITELIST
      self.attr_whitelist             = ATTR_WHITELIST
      self.app_user_object            = APP_USER_OBJECT
      self.app_user_auth_method       = APP_USER_AUTH_METHOD
      self.app_user_name_method       = APP_USER_NAME_METHOD
      self.article_review_period      = ARTICLE_REVIEW_PERIOD
      self.article_review_prompt_days = ARTICLE_REVIEW_PROMPT_DAYS
    end

    def validate
      validate_config_option(option: 'tag_whitelist',              expected_class: Enumerable,              example: '%w[a p strong]')
      validate_config_option(option: 'attr_whitelist',             expected_class: Enumerable,              example: '%w[class href]')
      validate_config_option(option: 'app_user_object',            expected_class: String,                  example: 'current_user')
      validate_config_option(option: 'app_user_auth_method',       expected_class: Symbol,                  example: ':admin?')
      validate_config_option(option: 'app_user_name_method',       expected_class: Symbol,                  example: ':name')
      validate_config_option(option: 'article_review_period',      expected_class: ActiveSupport::Duration, example: '1.year')
      validate_config_option(option: 'article_review_prompt_days', expected_class: Integer,                 example: '30')
    end

    def validate_config_option(option:, expected_class:, example:)
      return unless !send(option.to_sym).is_a? expected_class
      raise Error::Config, "#{config_error_prefix} #{option} must be #{expected_class}, e.g. #{example}"
    end

    def config_error_prefix
      "Dokno configuration error (check config/initializers/dokno.rb):"
    end
  end
end
