module Dokno
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception

    include UserConcern
    include PaginationConcern

    add_flash_types :green, :yellow, :red
  end
end
