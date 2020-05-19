module CursorPaginator
  class << self
    attr_accessor :paginator

    def paginate(original_scope, **options)
      if original_scope.is_a?(Array)
        Paginator::Array.new(**options).paginate(original_scope)
      else
        paginator.new(**options).paginate(original_scope)
      end
    end
  end
end

require "active_support/core_ext"

require_relative "cursor_paginator/version"
require_relative "cursor_paginator/paginator"
require_relative "cursor_paginator/options_parser"
require_relative "cursor_paginator/pagination_result"
