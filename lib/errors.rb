module Checkers
  class InvalidMoveError < StandardError
    attr_reader :start_pos, :end_pos

    def initialize(start_pos, end_pos, message = "")
      super(message)

      @start_pos, @end_pos = start_pos, end_pos
    end
  end
end
