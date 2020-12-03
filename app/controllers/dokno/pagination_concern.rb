module Dokno
  module PaginationConcern
    extend ActiveSupport::Concern

    def paginate(records, max_per_page: 10)
      @page           = params[:page].to_i
      @total_records  = records.size
      @total_pages    = (@total_records.to_f / max_per_page).ceil
      @total_pages    = 1 unless @total_pages.positive?
      @page           = 1 unless @page.positive? && @page <= @total_pages

      records.offset((@page - 1) * max_per_page).limit(max_per_page)
    end
  end
end
