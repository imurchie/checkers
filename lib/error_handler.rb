module Checkers
  module ErrorHandler
    def reset_errors
      @errors = []
    end

    def add_error(error_text)
      @errors << error_text
    end

    def errors
      @errors
    end

    def errors?
      @errors.length > 0
    end
  end
end
