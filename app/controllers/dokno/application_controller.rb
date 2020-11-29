module Dokno
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception
    include Dokno::UserConcern
  end
end
