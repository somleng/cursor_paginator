module CursorPaginator
  module Paginator
  end
end

require_relative "paginator/base"
require_relative "paginator/array"

if defined?(::ActiveRecord)
  require_relative "paginator/active_record"

  CursorPaginator.paginator = CursorPaginator::Paginator::ActiveRecord
end
