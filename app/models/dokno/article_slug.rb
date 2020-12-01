module Dokno
  class ArticleSlug < ApplicationRecord
    belongs_to :article

    validates :slug, presence: true
  end
end
