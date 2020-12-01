module Dokno
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception
    include UserConcern
    include PaginationConcern
  end
end
