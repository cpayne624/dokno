module Dokno
  def self.configure
    yield config
    config.validate
  end

  def self.config
    @config ||= Dokno::Config.new
  end

  def self.config=(val)
    @config = val
  end

  class Config
    # (String) Host application name for display within the mounted dashboard
    attr_accessor :app_name

    # (Enumerable) Determines which HTML tags are allowed in Article markdown
    attr_accessor :tag_whitelist

    # (Enumerable) Determines which HTML attributes are allowed in Article markdown
    attr_accessor :attr_whitelist

    # Defaults
    TAG_WHITELIST  = %w[code img h1 h2 h3 h4 h5 h6 a em u i b strong ol ul li table thead tbody tfoot tr th td blockquote hr br p]
    ATTR_WHITELIST = %w[src alt title href target]

    def initialize
      self.app_name       = Rails.application.class.module_parent.name.underscore.humanize.upcase
      self.tag_whitelist  = TAG_WHITELIST
      self.attr_whitelist = ATTR_WHITELIST
    end

    def validate
      validate_tag_whitelist
      validate_attr_whitelist
    end

    def validate_tag_whitelist
      return unless !tag_whitelist.is_a?(Enumerable)

      raise "#{config_error_prefix} tag_whitelist must be Enumerable"
    end

    def validate_attr_whitelist
      return unless !attr_whitelist.is_a?(Enumerable)

      raise "#{config_error_prefix} attr_whitelist must be Enumerable"
    end

    def config_error_prefix
      "Dokno configuration error (check the config/initializers/dokno.rb file):"
    end
  end
end
