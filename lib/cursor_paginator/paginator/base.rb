module CursorPaginator
  module Paginator
    class Base
      SORT_DIRECTIONS = %i[asc desc].freeze

      attr_reader :options_parser, :paginator_options
      delegate :cursor_direction, :page_size, to: :options_parser

      def initialize(page_options: {}, paginator_options: {})
        @options_parser = OptionsParser.new(page_options)
        @paginator_options = paginator_options.reverse_merge(
          order_key: :id,
          primary_key: :id,
          sort_direction: :desc
        )
      end

      def take_records(records, limit)
        records.take(limit)
      end

      private

      def query_operator
        return cursor_direction.after? ? :gt : :lt if sort_direction == :asc
        return cursor_direction.after? ? :lt : :gt if sort_direction == :desc
      end

      def order_direction
        cursor_direction.after? ? sort_direction : opposite_sort_direction
      end

      def sort_direction
        paginator_options.fetch(:sort_direction)
      end

      def opposite_sort_direction
        SORT_DIRECTIONS.find { |i| i != sort_direction }
      end
    end
  end
end
