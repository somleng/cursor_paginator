module CursorPaginator
  class Paginator < BasePaginator
    def paginate(scope)
      records = scope.reorder(paginator_options.fetch(:order_key) => order_direction)
      records = filter_by_cursor(records) if options_parser.filter_required?

      PaginationResult.new(records, self)
    end

    private

    def filter_by_cursor(collection)
      arel_table      = collection.arel_table
      order_column    = arel_table[paginator_options.fetch(:order_key)]
      primary_column  = arel_table[paginator_options.fetch(:primary_key)]
      cursor_select   = arel_table.project(order_column).where(primary_column.eq(options_parser.cursor))
      where_clause    = cursor_direction.after? ? order_column.lt(cursor_select) : order_column.gt(cursor_select)

      collection.where(where_clause)
    end
  end
end
