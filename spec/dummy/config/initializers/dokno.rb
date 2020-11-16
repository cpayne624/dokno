Dokno.configure do |config|
  config.tag_whitelist  = %w[h1 h2 h3 h4 h5 h6 div p b strong u i em br hr table thead tbody tfoot tr th td a]
  config.attr_whitelist = %w[href target]
end