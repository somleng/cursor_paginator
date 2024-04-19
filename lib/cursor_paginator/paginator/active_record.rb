module CursorPaginator
  module Paginator
    class ActiveRecord < Base
      def paginate(scope)
        records = scope.reorder(paginator_options.fetch(:order_key) => order_direction)
        records = filter_by_cursor(records) if options_parser.filter_required?

        PaginationResult.new(records, self)
      end

      def take_records(records, limit)
        return super if records.limit_value.blank?

        super(records, [ records.limit_value, limit ].min)
      end

      private

      def filter_by_cursor(collection)
        arel_table      = collection.arel_table
        order_column    = arel_table[paginator_options.fetch(:order_key)]
        primary_column  = arel_table[paginator_options.fetch(:primary_key)]
        cursor_select   = arel_table.project(order_column).where(primary_column.eq(options_parser.cursor))
        where_clause = order_column.public_send(query_operator, cursor_select)

        collection.where(where_clause)
      end
    end
  end
end
