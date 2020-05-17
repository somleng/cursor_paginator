module CursorPaginator
  class DynamoidPaginator < BasePaginator
    def paginate(scope)
      if options_parser.filter_required?
        cursor = scope.source.where(paginator_options.fetch(:primary_key) => options_parser.cursor).first
        return PaginationResult.new([], self) if cursor.blank?
      end

      records = scope.record_limit(page_size + 1).start(cursor)
      PaginationResult.new(records, self)
    end
  end
end
