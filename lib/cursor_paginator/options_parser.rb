module CursorPaginator
  MIN_ITEMS = 1
  MAX_ITEMS = 100
  DEFAULT_LIMIT = 10

  class OptionsParser
    attr_reader :options

    def initialize(options = {})
      @options = options.deep_dup
      @options[:size] = normalize_page_size
    end

    def filter_required?
      cursor.present?
    end

    def cursor
      options[:before].presence || options[:after].presence
    end

    def cursor_direction
      (after_direction? ? "after" : "before").inquiry
    end

    def page_size
      @options[:size]
    end

    private

    def after_direction?
      options[:before].blank?
    end

    def normalize_page_size
      result = options.fetch(:size, DEFAULT_LIMIT).to_i
      [[result, MIN_ITEMS].max, MAX_ITEMS].min
    end
  end
end
