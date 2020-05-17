module CursorPaginator
  class PaginationResult
    include Enumerable

    attr_reader :records_scope, :paginator

    delegate :each, :size, to: :records

    def initialize(records_scope, paginator)
      @records_scope = records_scope
      @paginator = paginator
    end

    def first_item_cursor
      return if paginator.cursor_direction.before? && last_page?
      return if records.empty?

      records.first.public_send(paginator.paginator_options.fetch(:primary_key))
    end

    def last_item_cursor
      return if paginator.cursor_direction.after? && last_page?
      return if records.empty?

      records.last.public_send(paginator.paginator_options.fetch(:primary_key))
    end

    def last_page?
      additional_record.blank?
    end

    private

    def records
      @records ||= load_records
    end

    def additional_record
      load_records if @records.nil?

      @additional_record
    end

    def load_records
      records = records_scope.take(paginator.page_size + 1)
      @additional_record = records.pop if records.size > paginator.page_size
      paginator.cursor_direction.after? ? records : records.reverse
    end
  end
end
