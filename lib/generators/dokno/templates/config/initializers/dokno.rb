Dokno.configure do |config|
  config.tag_whitelist  = %w[div p b strong u i em br hr table thead tbody tfoot tr th td]
  config.attr_whitelist = %w[href]
end