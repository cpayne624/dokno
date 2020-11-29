module Dokno
  class Log < ApplicationRecord
    belongs_to :article

    default_scope { order(created_at: :desc) }
  end
end
