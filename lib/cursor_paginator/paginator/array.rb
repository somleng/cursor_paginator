module CursorPaginator
  module Paginator
    class Array < Base
      def paginate(scope)
        records = scope.sort_by(&paginator_options.fetch(:order_key))
        records = filter_by_cursor(records) if options_parser.filter_required?
        records = records.reverse if order_direction == :desc

        PaginationResult.new(records, self)
      end

      private

      def filter_by_cursor(collection)
        cursor_index = find_cursor_index(collection)
        return [] if cursor_index.blank?

        left, right = split_collection(collection, cursor_index)

        query_operator == :lt ? left : right
      end

      def find_cursor_index(collection)
        collection.index do |item|
          item.public_send(paginator_options.fetch(:primary_key)) == options_parser.cursor
        end
      end

      def split_collection(collection, cursor_index)
        left, right = collection.partition.with_index { |_, i| i <= cursor_index }
        left.pop

        [left, right]
      end
    end
  end
end
