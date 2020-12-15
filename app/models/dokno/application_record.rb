module Dokno
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    include Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper
  end
end
